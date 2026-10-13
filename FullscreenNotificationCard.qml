import QtQuick
import Quickshell.Services.Notifications
import qs.Common
import qs.Widgets

Item {
    id: root
    required property var notificationData
    property bool privacyMode: false
    readonly property string appName: notificationData ? notificationData.appName : "Notification"
    signal activated()
    signal dismissed()

    implicitHeight: Math.max(icon.height, textColumn.implicitHeight) + Theme.spacingM * 2
    height: implicitHeight
    StyledRect {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh
        border.width: 1
        border.color: root.notificationData && root.notificationData.urgency === NotificationUrgency.Critical
            ? Theme.error : Theme.outlineVariant
        DankCircularImage {
            id: icon
            x: Theme.spacingM
            y: Theme.spacingM
            width: Theme.iconSizeLarge
            height: width
            imageSource: root.notificationData ? root.notificationData.displayImage : ""
            fallbackIcon: root.notificationData ? root.notificationData.fallbackIconName : "material:notifications"
            fallbackText: root.appName.charAt(0).toUpperCase()
            cacheImages: false
        }
        Column {
            id: textColumn
            x: icon.x + icon.width + Theme.spacingM
            y: Theme.spacingM
            // Long titles cannot overlap the enlarged close hit target.
            width: Math.max(0, parent.width - x - closeButton.width - Theme.spacingS)
            spacing: Theme.spacingXS
            StyledText {
                width: parent.width
                text: root.appName
                textFormat: Text.PlainText
                color: Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
            }
            StyledText {
                width: parent.width
                text: root.notificationData ? root.notificationData.summary : ""
                visible: text.length > 0
                textFormat: Text.PlainText
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            StyledText {
                width: parent.width
                text: root.notificationData ? root.notificationData.body : ""
                visible: !root.privacyMode && text.length > 0
                textFormat: Text.PlainText
                color: Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                maximumLineCount: 4
                elide: Text.ElideRight
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
        DankActionButton {
            id: closeButton
            objectName: "dismissButton"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: Theme.spacingXS
            iconName: "close"
            iconColor: Theme.surfaceVariantText
            tooltipText: "Dismiss"
            onClicked: root.dismissed()
        }
    }
}
