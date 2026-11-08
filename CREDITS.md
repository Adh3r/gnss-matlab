# Credits and attribution

## Authors — NACC Lab Group 18 (EETAC-UPC, 2026)
- Oscar Gonzalo Aran
- Adam Ruiz Herrero

## Code provided by the course (used as-is or lightly adapted)
| File | Origin | Changes in this repository |
|------|--------|-----------------------------|
| `src/plot/plotworld.m` | NACC course material | reads the map from `data/maps/` |
| `src/time/gpstime.m` | NACC course material | HTTPS Celestrak URL, `websave`, almanacs stored in `data/almanacs/` |
| `src/time/time2toa.m`, `src/time/JDfromUTC.m` | NACC course material (JD algorithm from the gAGE book) | none |
| `src/io/almanac.m` | NACC course material | HTTPS, `websave` with `urlwrite` fallback, error handling, `data/almanacs/` store |
| `src/plot/viewsat.m` | NACC course material | restyled; `main4` draws its own sky plot |
| `src/time/greenwichMeanSiderealTime.m`, `src/time/earthRotationAngle.m` | [astrogreg.com](https://astrogreg.com/snippets/greenwichMeanSiderealTime.html), after G. H. Kaplan, *The IAU Resolutions on Astronomical Reference Systems* | none |

The structure of the `main1`–`main6` scripts and the function signatures and debug `fprintf`
lines follow the prototypes in the course statements. The function bodies, the closed-form
`ecef2lla`, the DOP and least-squares implementations, the interactive sky plot and all the
analysis are the group's work.

## Data
- GPS YUMA almanacs: [CelesTrak](https://celestrak.org/GPS/almanac/YUMA/).
- IRIDIUM 170 TLE (`data/tle/Group_18.tle`) and pseudoranges (`data/measurements/Group_18.dat`):
  assigned by the course.
- Coastlines (`data/maps/world_110m.txt`): course material.
- Reference screenshots `results/figures/*_gnssmp_reference.*`: [GNSS Mission Planning](https://www.gnssmissionplanning.com).

The course statements are not included in this repository.

## Development assistance
Claude (Anthropic) acted as a development assistant for code refactoring, test scaffolding and
documentation. The engineering, the analysis and the authorship belong to the lab group.
