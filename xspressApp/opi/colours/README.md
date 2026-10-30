# EDM colour schemes

Each directory here is a colour scheme for the EDM screens: it holds the
`colors.list` that `stxspress-gui --colours <name>` gives EDM in place of the
installed one. The screens are not changed; they refer to colours by
`colors.list` index, so a different file re-colours them.

`classic` is the default and has no directory here: it is the `colors.list`
installed with EDM (`qd-epics-edm`, from QD-odin-build `edm_config/`).

`qd` is a Quantum Detectors scheme: brand-tinted greys, dark readback
backgrounds and a QD-blue banner. It keeps every index and name of the classic
file and adds two entries. The main changes:

- 48 "CO title" is the QD logo blue `#0a72b9`, so the screen banners turn QD
  blue. Their dark title text reads at about 3.1:1 on it.
- 6 "Title" is a neutral grey, the "stopped / unknown" state colour.
- 21 "Monitor: MAJOR" is a dark red that reads on light buttons ("Stop").
- 85 "Alarm text: MINOR" and 86 "Alarm text: MAJOR" are new, light enough
  for the dark readback background, and the `alarm` block names them for
  MINOR and MAJOR readbacks.
- 15, 20 and 35, the "On" LED colours, are bright green, red and amber.

`qd/colors.list` is generated, with contrast and colour-vision checks, by
`build.py` in the QD notes (`edm-colour-schemes/`). Change it there and copy
the result here rather than editing it by hand. The first line must stay
`4 0 0`.
