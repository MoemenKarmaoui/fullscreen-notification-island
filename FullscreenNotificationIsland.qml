pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Modules.Plugins
import "NotificationLogic.js" as Logic

PluginComponent {
    id: root
    readonly property bool overlayEnabled: Logic.boolSetting(pluginData, "overlayEnabled", true)
    readonly property bool onlyWhenFullscreen: Logic.boolSetting(pluginData, "onlyWhenFullscreen", true)
    readonly property bool focusedScreenOnly: Logic.boolSetting(pluginData, "focusedScreenOnly", true)
    readonly property bool compactMode: pluginData && pluginData.displayMode === "island"
    readonly property bool animationsEnabled: Logic.boolSetting(pluginData, "animationsEnabled", true)
    readonly property bool showCount: Logic.boolSetting(pluginData, "showCount", true)
    readonly property int animationDuration: animationsEnabled ? Math.max(0, Theme.shortDuration) : 0
    readonly property int maxVisible: Logic.numberSetting(pluginData, "maxVisible", 4, 1, 6)
    readonly property int cardWidth: Logic.numberSetting(pluginData, "cardWidth", 420, 260, 640)
    readonly property int islandWidth: Logic.numberSetting(pluginData, "islandWidth", cardWidth, 200, 640)
    readonly property int topMargin: Logic.numberSetting(pluginData, "topMargin", 18, 0, 96)
    readonly property int rightMargin: Logic.numberSetting(pluginData, "rightMargin", 18, 0, 96)
    readonly property bool sessionLocked: IdleService.isShellLocked || SessionService.locked || SessionService.lockedHint

    // Dependencies include both list membership and the fields read from each
    // wrapper, so notification replacements also update without polling.
    property int notificationRevision: 0
    readonly property var liveEntries: {
        root.notificationRevision;
        return Logic.snapshots(NotificationService.visibleNotifications || []);
    }
    property var renderedEntries: []
    property bool exiting: false
    property int windowStateRevision: 0
    readonly property var cardsModel: renderedEntries.slice(-maxVisible)
    readonly property var latestEntry: renderedEntries.length ? renderedEntries[renderedEntries.length - 1] : null
    onLiveEntriesChanged: Qt.callLater(syncPopups)
    Component.onCompleted: syncPopups()

    function syncPopups() {
        if (liveEntries.length) {
            exitTimer.stop();
            exiting = false;
            if (!Logic.sameEntries(renderedEntries, liveEntries))
                renderedEntries = liveEntries;
        } else if (renderedEntries.length && !exiting) {
            // Unrelated changes cannot restart and prolong an exit.
            exiting = true;
            if (animationDuration > 0)
                exitTimer.start();
            else
                finishExit();
        }
    }

    function finishExit() {
        renderedEntries = [];
        exiting = false;
    }

    function liveWrapper(entry) {
        if (!entry || !entry.source || exiting || sessionLocked)
            return null;
        const wrappers = NotificationService.visibleNotifications || [];
        return wrappers.indexOf(entry.source) !== -1 && entry.source.popup ? entry.source : null;
    }

    function activate(entry) {
        const wrapper = liveWrapper(entry);
        if (!wrapper)
            return;
        try {
            Logic.activateDefault(wrapper);
        } catch (error) {
            console.warn("FullscreenNotificationIsland: activation failed:", error);
        }
    }

    function dismiss(entry) {
        const wrapper = liveWrapper(entry);
        if (wrapper)
            NotificationService.dismissNotification(wrapper);
    }

    Timer {
        id: exitTimer
        interval: Math.max(1, root.animationDuration)
        onTriggered: root.finishExit()
    }

    Connections {
        target: NotificationService
        ignoreUnknownSignals: true
        function onVisibleNotificationsChanged() { root.notificationRevision++; }
        function onNotificationDeduplicated() { root.notificationRevision++; }
    }

    Connections {
        target: CompositorService
        function onToplevelsChanged() { root.windowStateRevision++; }
    }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                id: win
                required property var modelData
                readonly property bool fullscreenOnScreen: {
                    root.windowStateRevision;
                    if (!modelData)
                        return false;
                    try {
                        return CompositorService.fullscreenToplevelOnScreen(modelData);
                    } catch (error) {
                        return false;
                    }
                }
                readonly property bool focusedScreen: {
                    root.windowStateRevision;
                    let focused = null;
                    try {
                        focused = CompositorService.getFocusedScreen();
                    } catch (error) {
                        focused = null;
                    }
                    // One fallback output avoids duplicates during hotplug.
                    const target = focused || Quickshell.screens[0];
                    return !!target && !!modelData && target.name === modelData.name;
                }
                readonly property bool shouldShow: root.overlayEnabled && !root.sessionLocked
                    && root.renderedEntries.length > 0
                    && (!root.onlyWhenFullscreen || fullscreenOnScreen)
                    && (!root.focusedScreenOnly || focusedScreen)
                readonly property real contentWidth: Math.min(root.compactMode ? root.islandWidth : root.cardWidth, Math.max(1, width - 16))

                screen: modelData
                color: "transparent"
                visible: shouldShow
                implicitHeight: Math.max(1, Math.ceil(content.height))
                anchors { top: true; left: true; right: true }
                margins.top: root.topMargin
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.exclusiveZone: -1
                WlrLayershell.namespace: "dms:plugins:fullscreen-notification-island"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                // Loader.item notifies when created; itemAtIndex() does not.
                mask: Region {
                    item: !root.exiting && content.presented && presentation.item
                        ? presentation.item.maskItem : null
                }

                Item {
                    id: content
                    property bool presented: false
                    width: win.contentWidth
                    height: presentation.item ? presentation.item.implicitHeight : 0
                    x: root.compactMode ? Math.round((parent.width - width) / 2)
                        : Math.max(8, parent.width - width - root.rightMargin)
                    opacity: presented && !root.exiting ? 1 : 0
                    scale: root.animationsEnabled && (!presented || root.exiting) ? 0.96 : 1
                    transformOrigin: Item.Top
                    Behavior on opacity {
                        NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
                    }
                    Loader {
                        id: presentation
                        width: parent.width
                        active: win.shouldShow
                        sourceComponent: root.compactMode ? compactFace : cardStack
                        onLoaded: {
                            content.presented = false;
                            Qt.callLater(function() {
                                if (presentation.item && win.shouldShow)
                                    content.presented = true;
                            });
                        }
                        onActiveChanged: {
                            if (!active)
                                content.presented = false;
                        }
                    }
                }

                Component {
                    id: compactFace
                    FullscreenNotificationCompact {
                        notificationData: root.latestEntry
                        maxPillWidth: win.contentWidth
                        otherCount: root.showCount ? Math.max(0, root.renderedEntries.length - 1) : 0
                        animationsEnabled: root.animationsEnabled
                        onActivated: root.activate(notificationData)
                        onDismissed: root.dismiss(notificationData)
                    }
                }
                Component {
                    id: cardStack
                    ListView {
                        id: stack
                        readonly property Item maskItem: stack
                        implicitHeight: Math.min(contentHeight, Math.max(1, win.modelData.height - root.topMargin - 16))
                        height: implicitHeight
                        spacing: Theme.spacingS
                        interactive: contentHeight > height
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true
                        model: root.cardsModel
                        delegate: FullscreenNotificationCard {
                            required property var modelData
                            width: stack.width
                            notificationData: modelData
                            privacyMode: SettingsData.notificationPopupPrivacyMode
                            onActivated: root.activate(notificationData)
                            onDismissed: root.dismiss(notificationData)
                        }
                        add: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: root.animationDuration }
                        }
                        displaced: Transition {
                            NumberAnimation { property: "y"; duration: root.animationDuration; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }
        }
    }
}
