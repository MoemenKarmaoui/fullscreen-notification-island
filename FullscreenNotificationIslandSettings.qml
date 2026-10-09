import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "fullscreenNotificationIsland"

    StyledText {
        text: "Fullscreen Notification Island"
        color: Theme.surfaceText
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.DemiBold
    }
    StyledText {
        width: parent.width
        text: "A temporary notification above fullscreen apps. Left-click opens the app's default action, or hides the popup if none is provided. Right-click dismisses it."
        color: Theme.surfaceVariantText
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
    }
    SelectionSetting {
        id: style
        settingKey: "displayMode"
        label: "Notification style"
        description: "Cards show message details; the island shows the latest app and title"
        defaultValue: "card"
        options: [
            { label: "Detailed card", value: "card" },
            { label: "Compact island", value: "island" }
        ]
    }
    ToggleSetting {
        settingKey: "overlayEnabled"
        label: "Enable overlay"
        description: "Display the selected notification style"
        defaultValue: true
    }
    ToggleSetting {
        settingKey: "onlyWhenFullscreen"
        label: "Only during fullscreen"
        description: "Hide this overlay over normal windows"
        defaultValue: true
    }
    ToggleSetting {
        settingKey: "focusedScreenOnly"
        label: "Focused screen only"
        description: "Show notifications on the output with keyboard focus"
        defaultValue: true
    }
    ToggleSetting {
        settingKey: "animationsEnabled"
        label: "Animate notifications"
        description: "Fade and gently scale in and out; smoothly resize the island"
        defaultValue: true
    }
    ToggleSetting {
        visible: style.value === "island"
        settingKey: "showCount"
        label: "Show other notification count"
        description: "Show +N for other currently active popups, excluding notification history"
        defaultValue: true
    }
    SliderSetting {
        visible: style.value !== "island"
        settingKey: "maxVisible"
        label: "Maximum visible cards"
        description: "Limit the stack; DMS controls which notifications are active and when they expire"
        defaultValue: 4
        minimum: 1
        maximum: 4
    }
    SliderSetting {
        visible: style.value !== "island"
        settingKey: "cardWidth"
        label: "Card width"
        description: "Cards also shrink to fit narrow displays"
        defaultValue: 420
        minimum: 260
        maximum: 640
        unit: "px"
    }
    SliderSetting {
        visible: style.value === "island"
        settingKey: "islandWidth"
        label: "Maximum island width"
        description: "The centered pill fits its text up to this width"
        defaultValue: root.loadValue("cardWidth", 420)
        minimum: 200
        maximum: 640
        unit: "px"
    }
    SliderSetting {
        settingKey: "topMargin"
        label: "Top margin"
        description: "Distance from the top edge of the screen"
        defaultValue: 18
        minimum: 0
        maximum: 96
        unit: "px"
    }
    SliderSetting {
        visible: style.value !== "island"
        settingKey: "rightMargin"
        label: "Right margin"
        description: "Distance of the card stack from the right edge"
        defaultValue: 18
        minimum: 0
        maximum: 96
        unit: "px"
    }
}
