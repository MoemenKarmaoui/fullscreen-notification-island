import QtQuick
import Quickshell.Services.Notifications
import qs.Common
import qs.Widgets

Item {
    id: root
    required property var notificationData
    property real maxPillWidth: 420
    property int otherCount: 0
    property bool animationsEnabled: true
    readonly property Item maskItem: pill
    readonly property string appName: notificationData ? notificationData.appName : "Notification"
    readonly property string lineText: notificationData && notificationData.summary
        && notificationData.summary !== appName ? appName + " · " + notificationData.summary : appName
    signal activated()
    signal dismissed()

    implicitWidth: maxPillWidth
    implicitHeight: 42
    height: implicitHeight

    StyledRect {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(root.maxPillWidth, Math.max(160, label.implicitWidth + icon.width
            + Theme.spacingS + Theme.spacingM * 2 + (badge.visible ? badge.width + Theme.spacingS : 0)))
        height: root.height
        radius: height / 2
        color: Theme.surfaceContainerHigh
        border.width: 1
        border.color: root.notificationData && root.notificationData.urgency === NotificationUrgency.Critical
            ? Theme.error : Theme.outlineVariant
        clip: true
        Behavior on width {
            enabled: root.animationsEnabled
            NumberAnimation { duration: Theme.shortDuration; easing.type: Easing.OutCubic }
        }

        Row {
            id: row
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingM
            anchors.rightMargin: Theme.spacingM
            spacing: Theme.spacingS
            DankCircularImage {
                id: icon
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: width
                imageSource: root.notificationData ? root.notificationData.displayImage : ""
                fallbackIcon: root.notificationData ? root.notificationData.fallbackIconName : "material:notifications"
                fallbackText: root.appName.charAt(0).toUpperCase()
                cacheImages: false
            }
            StyledText {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(0, row.width - icon.width - row.spacing
                    - (badge.visible ? badge.width + row.spacing : 0))
                text: root.lineText
                textFormat: Text.PlainText
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
            StyledText {
                id: badge
                visible: root.otherCount > 0
                anchors.verticalCenter: parent.verticalCenter
                text: "+" + root.otherCount
                textFormat: Text.PlainText
                color: Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
            }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton)
                    root.dismissed();
                else
                    root.activated();
            }
        }
    }
}
