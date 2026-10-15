# xspress-detector-ioc

EPICS IOC for the Quantum Detectors Xspress detector system. It talks to the
Xspress odin-control server over REST through the ADOdin driver and comes with
its EDM screens and a GUI launcher.

## Layout

| Path | Contents |
| --- | --- |
| `configure/` | EPICS build configuration (`RELEASE`, `CONFIG_SITE`) |
| `xspressApp/src/` | The `xspress` IOC executable |
| `xspressApp/Db/` | `xspress-substitutions.sh`, which makes one database per card count |
| `xspressApp/opi/edl/` | EDM screens, the `stxspress-gui` launcher and its desktop entry |
| `iocBoot/iocxspress/` | Start-up script `stxspress.boot`; `envPaths` is written by make |

## Build

Needs EPICS base 7 and these support modules: sequencer, sscan, calc, asyn,
autosave, busy, ADSupport, ADCore, restClient, ADOdin and procServControl
(its screens only).

1. Put the module paths in `configure/RELEASE.local`, e.g.

   ```make
   SUPPORT = /opt/epics/support
   EPICS_BASE = /opt/epics/base
   ```

2. Optionally, set the GUI launcher settings in `configure/CONFIG_SITE.local`
   (see `configure/CONFIG_SITE`): `XSPRESS_GUI_ENV`, a shell script that sets
   up EDM, and `XSPRESS_IOC_ENV`, the file that holds `XSPRESS_NUM_CARDS`.
3. Run `make`.

The build writes absolute paths (`envPaths`, the launcher and the desktop
entry), so build the IOC where it will run.

## Run

The start-up script expects odin-control on `127.0.0.1:8888` and the live view
merge on `tcp://127.0.0.1:15550`. Start the IOC from `iocBoot/iocxspress`:

```sh
cd iocBoot/iocxspress
XSPRESS_NUM_CARDS=4 ../../bin/linux-x86_64/xspress stxspress.boot
```

A copy of `stxspress.boot` elsewhere works too, as long as the IOC starts in
`iocBoot/iocxspress`.
`EPICS_CA_MAX_ARRAY_BYTES` must be large enough for the live view array
(`XSPRESS:ARR`).

### Number of cards

`XSPRESS_NUM_CARDS` (default 4) is the number of cards, each with one frame
receiver / frame processor pair and two channels. The IOC loads
`db/xspress_<N>card.db`, so N must be one of the counts built by
`xspressApp/Db/Makefile`: 1, 2, 4, 8, 9 or 16, the counts with an ADOdin
`OdinDataStatus<N>.edl` screen. For any other value the IOC stops before
`iocInit`.

## GUI

`bin/linux-x86_64/stxspress-gui` opens `xspressTop.edl` (`-d` for edit mode).
It reads `XSPRESS_NUM_CARDS` from the environment, else from the
`XSPRESS_IOC_ENV` file, and picks the screens that depend on it:

- `OdinDataStatus<N>.edl` (ADOdin);
- the 8-channel screens up to 4 cards, the 36-channel screens above;
- the MCA screen always shows channels 1-8.

`share/applications/qd-xspress-gui.desktop` starts the launcher.
