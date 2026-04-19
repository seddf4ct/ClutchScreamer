# ClutchScreamer 🚦

A CSP Lua app for Assetto Corsa that reminds you to hold and release the clutch at race starts.

- Displays **"CLUTCH!"** with a pulsing overlay in the last 10 seconds before lights out
- Displays **"CLUTCH OUT!"** with a strobing flash and beep the moment lights go out
- Works with the **[OSR startLights server script](https://github.com/tetematete/OSRLUASNIPPETS)** or standalone
- Volume control with test button in the settings window

---

## Preview

| Holding clutch | Lights out |
|---|---|
| Purple pulsing overlay + "CLUTCH!" | Red/orange strobe + "CLUTCH OUT!" + beep |

---

## Requirements

- Assetto Corsa
- [Custom Shaders Patch (CSP)](https://acstuff.ru/patch/) — any recent version

---

## Installation

1. Download or clone this repo
2. Copy the `ClutchScreamer` folder into:
   ```
   steamapps/common/assettocorsa/apps/lua/
   ```
3. Launch Assetto Corsa
4. Enable the app from **Options → General → Apps**
5. Add it to your HUD from the in-game app taskbar

Your folder structure should look like this:
```
assettocorsa/
└── apps/
    └── lua/
        └── ClutchScreamer/
            ├── ClutchScreamer.lua
            ├── manifest.ini
            ├── beep.wav
            └── icon.png
```

---

## Settings

Open the **ClutchScreamer Settings** window from the app taskbar to:

- Adjust beep volume in 10% steps
- Test the beep sound
- See whether the app is running in OSR or Standalone mode

---

## OSR startLights Compatibility

When running on a server using the [OSR startLights script](https://github.com/tetematete/OSRLUASNIPPETS/blob/main/Server%20Scripts/startLights.lua), ClutchScreamer automatically detects the `triggerStart` event and syncs its timing precisely to the server's light sequence.

If the server script is not present, ClutchScreamer falls back to using `sim.timeToSessionStart` for standalone/offline use.

| Mode | Detection |
|---|---|
| OSR Server | `ac.OnlineEvent` — "Start Lights" |
| Standalone | `sim.timeToSessionStart` |

---

## Files

| File | Description |
|---|---|
| `ClutchScreamer.lua` | Main app script |
| `manifest.ini` | CSP app manifest |
| `beep.wav` | Lights out beep sound |
| `icon.png` | App taskbar icon |

---

## License

MIT — do whatever you want with it.
