# HydraDesk

HydraDesk is a modular native macOS productivity suite built with Swift + SwiftUI.

## Project layout

- `HydraDesk/Sources/HydraDesk/App` – app entry points
- `HydraDesk/Sources/HydraDesk/Core` – reusable components/utilities
- `HydraDesk/Sources/HydraDesk/Models` – module models
- `HydraDesk/Sources/HydraDesk/Services` – macOS integrations and persistence services
- `HydraDesk/Sources/HydraDesk/ViewModels` – MVVM view model layer
- `HydraDesk/Sources/HydraDesk/Views` – sidebar/dashboard/module UI
- `HydraDesk/Sources/HydraDesk/Resources` – resources placeholder

## Features implemented

- Sidebar navigation + frosted glass UI cards
- Dashboard + foundations for all required modules
- Real-time system stats service (CPU/memory/disk/battery/network)
- Spotlight-style launcher with search and launch/open actions
- Clipboard history with pinning and cleanup
- Wallpaper management foundation
- Network controls with best-effort toggles/status
- Notification history persistence
- Workspace save/restore with presets
- Quick settings (dark mode/focus/brightness/volume)
- Tasks module with todo + focus timer + productivity metric
- Menu bar popover mini dashboard
- Global launcher hotkey registration

## Build

On macOS:

```bash
cd HydraDesk
swift run
```

Open `HydraDesk/Package.swift` in Xcode to run as a native macOS app.
