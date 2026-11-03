# Xspress Phoebus screens

Display Builder (`.bob`) versions of the EDM screens in `../edl`, in the QD
Phoebus theme from the `qd-phoebus` RPM (named colours, fonts and widget
classes; the header logo is `$(theme_root)/header_logo.png`, which the
`phoebus` launcher sets). They give access to the same PVs as the EDM screens.
The layout is fixed at 4 cards / 8 channels.

PV names use macros the way the EDM screens do: `P=XSPRESS`, with
`R=:CAM:`, `:OD:` or `:ARR:` for the detector and `R=:SC:` for service
control.

## Opening

```bash
phoebus -resource "file:/opt/QD/epics/ioc/xspress/xspressApp/opi/bob/xspress.bob?P=XSPRESS"
phoebus -resource "file:/opt/QD/epics/ioc/xspress/xspressApp/opi/bob/xspress_services.bob?P=XSPRESS&R=:SC:"
```

The main window's header buttons open the MCA spectra, live view and
services screens in new tabs of the Phoebus window.
The MCA tab shows one plot per channel or all channels on one plot;
its Overlay / Per channel button switches between the two.
The MCA and live view screens are 800 px wide; the pop-out button at the
right of their header (`pop_out.svg`) opens a 1600 × 896 copy of the same
screen, the `_large.bob` file, in a new window.

## Screens

| File | Shows | Macros |
|---|---|---|
| `xspress.bob` | Main window: header, service state, navigation tabs | `P` |
| `xspress_detector.bob` | Tab: info, acquisition, status, detector, image, configuration, adapter (EDM `XspressMain`) | `P`, `R=:CAM:` |
| `xspress_channels.bob` | Tab: window counts and limits, counts and timing per channel (EDM `Xspress8Channels`, `XspressStatus8Chan2Fem` frames) | `P`, `R=:CAM:` |
| `xspress_dtc.bob` | Tab: dead-time correction parameters per channel, beam energy (EDM `Xspress8ChannelsDTC`) | `P`, `R=:CAM:` |
| `xspress_status.bob` | Tab: cards (FEM) and OdinData processes (EDM `XspressStatus8Chan2Fem`, `OdinDataStatus4`) | `P`, `R=:CAM:` |
| `xspress_data.bob` | Tab: OdinData driver, HDF5 writer, array plugin, meta writer, live view, Blosc (EDM `XspressDAQMain`, `LiveViewPlugin`, `BloscPlugin`, ARR) | `P`, `R=:OD:` |
| `xspress_expert.bob` | Tab: settings files, detector configuration, Xspress and control application commands, IOC scan rates (EDM `XspressAll`) | `P`, `R=:CAM:` |
| `xspress_hdf5_advanced.bob` | Window: HDF5 dataset and file settings (EDM `OdinDataHDF5Advanced`) | `P`, `R=:OD:` |
| `xspress_mca.bob` | Tab: MCA spectrum of each channel (EDM `Xspress8ChanMCA`) | `P`, `R=:CAM:` |
| `xspress_mca_overlay.bob` | Tab: all channels' MCA spectra on one plot, one colour per channel (`Trace_1`–`Trace_8`) with a legend; the header button switches between this and `xspress_mca.bob` in place | `P`, `R=:CAM:` |
| `xspress_liveview.bob` | Tab: live spectrum and its channel / resgrade index (EDM `XspressLiveView`) | `P`, `R=:CAM:` |
| `xspress_mca_large.bob`, `xspress_mca_overlay_large.bob`, `xspress_liveview_large.bob` | Window: 1600 × 896 copies of the three screens above, opened by their pop-out button; their header buttons open the other large screens | `P`, `R=:CAM:` |
| `xspress_services.bob` | Tab: wiring diagram of the services, their connections and the stack state (EDM `xspress-sc-wiring`) | `P`, `R=:SC:` |
| `xspress_service_edges.bob` | Tab: every connection's state (EDM `xspress-sc-edges`) | `P`, `R=:SC:` |
| `xspress_service.bob` | Window: one service's unit, state, controls, listeners and journal (EDM `xspress-sc-<service>`) | `P`, `R`, `SVC` (e.g. `FR1`), `DESC`, `LISTENERS` (`fr`, `fp`, `xctrl`, `meta`, `lvm`, `odin`, `ioc`) |

Components embedded by the screens above:

| File | Used by | Macros |
|---|---|---|
| `xspress_channel_windows.bob`, `xspress_channel_counts.bob`, `xspress_channel_dtc.bob` | channel tables, one row per channel | `P`, `R`, `CHAN` |
| `xspress_fem.bob` | status tab, one row per card | `P`, `R`, `CARD` (0–3) |
| `xspress_odin_data.bob` | status tab, one row per OdinData process | `P`, `RANK` (1–4) |
| `xspress_service_block.bob` | wiring diagram, one block per service | `P`, `R`, `SVC`, `DESC`, `LISTENERS` |
| `xspress_service_listeners_<family>.bob`, `xspress_service_listener.bob` | service window, its listeners | `P`, `R`, `SVC` / `EL`, `NAME` |
| `xspress_service_edge.bob` | connections window, one row per connection | `P`, `R`, `EL` |

## Colours

LEDs use the theme's bright-on / dark-off pairs: green for connected, ready or
running, amber for waiting or "reconfigure required", red for errors.
Service states are unknown (light grey), stopped (dark green), waiting
(amber), ready (green) and fault (red). In the wiring diagram a connection
is dark grey when it's made, amber while waiting, red on a fault and light
grey when stopped or unknown; dashed connections are made after `xspress_ioc`
is up.
