# 8-Bit 250-MS/s Differential Current-Steering DAC in 0.18 µm CMOS

This project implements an 8-bit, 250-MS/s differential current-steering DAC in TSMC 0.18 µm CMOS. The repository includes Cadence-exported netlists, cleaned Spectre `.scs` files, MATLAB post-processing scripts, CSV data, and a Markdown project report.

## Project Summary

This is the final project for ELEN 6316 Analog-Digital Interfaces in VLSI, Spring 2026.

The DAC uses eight binary-weighted NMOS current-steering bit cells with weights from 1 to 128. Each bit cell includes a 6-bit analog trim DAC for current-weight calibration. A NAND-latch-based input retimer aligns all digital inputs with the sampling clock, and a 100 uA NMOS-mirror bias generator provides the shared current-source bias.

The design targets a 1.8 V supply, 1.5 Vpp differential output swing, 100 ohm differential output resistance, 25 ohm common-mode output resistance, and SFDR above 48 dB.

## Contributors

Yi-Hsiang Wei and Zijian Shang are students in Columbia University's Department of Electrical Engineering.

- Yi-Hsiang Wei: system-level and transistor-level schematic design, Cadence Virtuoso implementation, and Spectre simulation.
- Zijian Shang: MATLAB result analysis and final report preparation.

## Key Results

| Metric | Result |
| --- | ---: |
| Resolution | 8 bits |
| Sample rate | 250 MS/s |
| Differential output swing | 1.50 Vpp |
| Differential output resistance | 98.76-99.84 ohm |
| Common-mode output resistance | 24.69-24.96 ohm |
| Worst-case SFDR | 48.2 dB |
| Peak DNL | < 0.18 LSB |
| Peak INL | < 0.24 LSB |
| Trim tuning range | -14.8% to +14.3% |
| TT total power | 51.0-60.8 mW |

## Files

- [DAC_Project_Report.md](DAC_Project_Report.md) - complete Markdown report.
- [figures/README.md](figures/README.md) - image placement guide for figures referenced by the Markdown report.
- [ELEN6316_Submission/docs/elen6316_submission.pdf](ELEN6316_Submission/docs/elen6316_submission.pdf) - class submission report.
- [ELEN6316_Submission/docs/project_requirements.pdf](ELEN6316_Submission/docs/project_requirements.pdf) - course project requirements.
- `Netlist_files/` - original Cadence-exported Spectre netlists and simulation testbenches.
- `Spectre_files/` - cleaned Spectre `.scs` files mirroring `Netlist_files/`.
- `Matlab_files/` - MATLAB analysis scripts and exported CSV data.
- `ELEN6316_Submission/` - organized submission package with report source, figures, results, and final PDFs.

## Repository Layout

```text
Netlist_files/
  Top-Level/          Original block-level Cadence Spectre exports
  test/               Original simulation testbenches
Spectre_files/
  Top-Level/          Cleaned block-level Spectre .scs files
  test/               Cleaned Spectre .scs testbenches
Matlab_files/
  Static/             INL/DNL and output swing analysis
  Dynamic/            SFDR, SNDR, ENOB, and spectrum analysis
  Tuning Range/       Per-bit trim range analysis
  Power/              Average power analysis
  Zout/               Output impedance analysis
  Retimer/            Retimer timing waveform analysis
figures/              Drop report images here for DAC_Project_Report.md
ELEN6316_Submission/  Final submission package
```

## Running Spectre Simulations

The preferred simulation inputs are in `Spectre_files/`. These files use Spectre syntax, have `.scs` extensions, and have had generated `//` comment lines removed. The original Cadence exports are preserved in `Netlist_files/`.

The testbenches include absolute model paths from the original environment:

```spectre
include "/homes/user/stud/fall25/yw4576/pdk/TSMC018_teaching.scs" section=tt
ahdl_include "/tools/cadence/IC618.270/tools/dfII/samples/artist/ahdlLib/adc_8bit_ideal/veriloga/veriloga.va"
```

Update those paths before running the simulations locally.

Example:

```sh
spectre Spectre_files/test/INL_DNL_test.scs
```

Useful testbenches:

- `Spectre_files/test/INL_DNL_test.scs`
- `Spectre_files/test/Tuniing_Range_test.scs`
- `Spectre_files/test/SNDR_SFDR_test.scs`
- `Spectre_files/test/Power_test.scs`
- `Spectre_files/test/Input_Retimer_test.scs`
- `Spectre_files/test/Output_cm_test.scs`
- `Spectre_files/test/Output_diff_test.scs`

## MATLAB Analysis

Run each MATLAB script from its own folder so the relative CSV paths resolve.

```matlab
cd Matlab_files/Dynamic
run("SFDR_SNDR_ENOB_all.m")
```

The main analysis scripts are in the `Matlab_files/` subdirectories.
