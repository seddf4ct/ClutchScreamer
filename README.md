# ClutchScreamer 🚦

A CSP Lua app for Assetto Corsa that reminds you to hold and release the clutch at race starts.

- Displays **"CLUTCH!"** with a pulsing overlay in the last 10 seconds before lights out
- Displays **"CLUTCH OUT!"** with a strobing flash and beep the moment lights go out
- **Wheelspin detector** — shows LIFT!, MORE THROTTLE! or PERFECT LAUNCH! after the start
- Works with the **[OSR startLights server script](https://github.com/tetematete/OSRLUASNIPPETS)** or standalone
- Volume control with test button in the settings window

---

## Demo

[![ClutchScreamer Demo](https://img.youtube.com/vi/b6am_CKiFRY/maxresdefault.jpg)](https://www.youtube.com/watch?v=b6am_CKiFRY)

---

## Preview

| Holding clutch | Lights out | After launch |
|---|---|---|
| Purple pulsing overlay + "CLUTCH!" | Red/orange strobe + "CLUTCH OUT!" + beep | Wheelspin feedback at the bottom |

---

## Requirements

- Assetto Corsa
- [Custom Shaders Patch (CSP)](https://acstuff.ru/patch/) — any recent version

---

## Installation

1. Download the latest release zip
2. Extract and copy the `ClutchScreamer` folder into:
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

## Wheelspin Detector

For 6 seconds after lights out, ClutchScreamer monitors your wheel slip ratio and shows one of three messages at the bottom of the overlay:

| Message | Meaning |
|---|---|
| 🔴 **LIFT!** | Too much wheelspin — ease off the throttle |
| 🔵 **MORE THROTTLE!** | Too much grip — you can push harder |
| 🟢 **PERFECT LAUNCH!** | Slip ratio is in the sweet spot |

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
