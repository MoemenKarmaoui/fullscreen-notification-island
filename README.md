# Fullscreen Notification Island

[![Vibe Coded](https://img.shields.io/badge/Vibe%20Coded%20with-ChatGPT%20Astra%20%26%20Antigravity-7928CA?style=for-the-badge&logo=openai&logoColor=white)](https://github.com/MoemenKarmaoui/fullscreen-notification-island)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![DMS Version](https://img.shields.io/badge/DMS-%3E%3D1.6.0-teal?style=for-the-badge)](https://github.com/AvengeMedia/dms)

![Fullscreen Notification Island preview](assets/preview.svg)

> ✨ **Note:** This whole plugin was proudly **vibe coded** from start to finish by **ChatGPT Astra** and **Antigravity**!

---

This DMS daemon plugin keeps the regular notification popup on its normal
`top` layer. When a notification is active and the focused output contains a
fullscreen toplevel, it creates a small click-through `overlay` layer-shell
surface on that output. The `Notification style` setting lets you choose
between a detailed card stack and a compact DankIsland-style pill. Both styles
use the DMS theme and follow DMS's own popup timeout, grouping, urgency, DND,
and queue policy. Card mode can show several active cards; island mode shows
the newest active popup and can add a `+N` count for the other active popups.

## ✨ Vibe Coded With

This entire plugin was vibe coded using:
- 🤖 **ChatGPT Astra**
- 🪐 **Antigravity**

Special thanks to modern AI tools for crafting the QML components, layer-shell integration, settings schemas, and DankMaterialShell optimizations!

## Install

Copy this directory as one unit into the DMS plugin directory:

```bash
mkdir -p ~/.config/DankMaterialShell/plugins
cp -r FullscreenNotificationIsland ~/.config/DankMaterialShell/plugins/
dms ipc call plugin-scan scan
```

When using the provided zip instead, run
`unzip -o FullscreenNotificationIsland.zip -d ~/.config/DankMaterialShell/plugins`
from the directory containing the zip.

Then open **DMS Settings → Plugins**, enable **Fullscreen Notification
Island**, and open its settings. If DMS was already running, use **Scan** (or
`dms ipc call plugin-scan rescan fullscreenNotificationIsland` followed by
`dms ipc call plugins reload fullscreenNotificationIsland`) after copying the
files. Collapse and reopen the plugin card if its settings panel was already
expanded; DMS keeps an expanded settings component alive while it rescans.

For a running DMS instance, you can enable it from a terminal after scanning:

```bash
dms ipc call plugins enable fullscreenNotificationIsland
dms ipc call plugins reload fullscreenNotificationIsland
```

Leave DMS's **Notification Overlay** option disabled, and keep the global
DankIsland **Use Overlay Layer** switch off. This plugin's small surface
selects the overlay layer by itself only while a fullscreen window has an
active notification, so the bar, dock, and full notification center do not
stay above fullscreen apps.

Test it while a fullscreen application is focused:

```bash
notify-send "Fullscreen island test" "This should appear over a fullscreen window"
```

The plugin uses DMS's existing timeout, dismissal, action, and queue behavior;
its settings control the style, animation, card stack, island width, and
monitor placement. A left click invokes only the notification's standard
`default` action; a right click or the close button dismisses it. If no default
action exists, a left click simply hides the temporary popup. Resident
notifications remain in DMS's notification center after their popup is hidden.

## Notes

The plugin requires DMS 1.6 or newer because it consumes the public
`NotificationService.visibleNotifications` list and
`CompositorService.fullscreenToplevelOnScreen()` helper. It does not start a
polling process or replace the notification server. Display fields are copied
before DMS destroys expired wrapper objects, so the exit animation never reads
from a stale notification. If a compositor cannot report fullscreen state,
turn **Only during fullscreen** off to use the overlay for every notification
as a compatibility fallback.

If critical notifications still appear as a second stock popup, set
`DMS_NOTIFICATION_LAYER=top` in the environment that launches DMS. DMS can
force critical stock popups onto its overlay layer otherwise; the environment
override keeps those stock popups below fullscreen apps while this plugin shows
the temporary island.
