# Fullscreen Notification Island


[![Vibe Coded](https://img.shields.io/badge/Vibe%20Coded%20with-ChatGPT%20Astra%20%26%20Antigravity-7928CA?style=for-the-badge&logo=openai&logoColor=white)](https://github.com/MoemenKarmaoui/fullscreen-notification-island)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![DMS Version](https://img.shields.io/badge/DMS-%3E%3D1.6.0-teal?style=for-the-badge)](https://github.com/AvengeMedia/dms)


![Fullscreen Notification Island preview](assets/preview-banner.svg)


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
