# 8-Bit 250-MS/s Differential Current-Steering DAC in 0.18 µm CMOS

This project implements an 8-bit, 250-MS/s differential current-steering DAC in TSMC 0.18 µm CMOS. The repository includes Cadence Spectre netlists, MATLAB post-processing scripts and CSV data, and a Markdown project report.

## Project Summary

This is the final project for ELEN 6316 Analog-Digital Interfaces in VLSI, Spring 2026.

The DAC uses eight binary-weighted NMOS current-steering bit cells with weights from 1 to 128. Each bit cell includes a 6-bit analog trim DAC for current-weight calibration. A NAND-latch-based input retimer aligns all digital inputs to the sampling clock, and a 100 uA NMOS-mirror bias generator provides the shared current-source bias.

The design targets a 1.8 V supply, 1.5 Vpp differential output swing, 100 ohm differential output resistance, 25 ohm common-mode output resistance, and SFDR above 48 dB.

## Contributors

Yi-Hsiang Wei and Zijian Shang are students in the Department of Electrical Engineering at Columbia University.

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

- [PROJECT_REPORT.md](PROJECT_REPORT.md) - full Markdown project report.
- [ELEN6316_Project_Requirements.pdf](ELEN6316_Project_Requirements.pdf) - course project requirements.
- [figures/README.md](figures/README.md) - image placement guide for figures referenced by the Markdown report.
- `Netlist/` - Spectre netlists and simulation test benches.
- `Matlab_file/` - MATLAB analysis scripts and exported CSV data.

## Repository Layout

```text
Netlist/
  Top-Level/          Block-level Spectre exports
  test/               Simulation benches for static, dynamic, power, and impedance tests
Matlab_file/
  Static/             INL/DNL and output swing analysis
  Dynamic/            SFDR, SNDR, ENOB, and spectrum analysis
  Tuning Range/       Per-bit trim range analysis
  Power/              Average power analysis
  Zout/               Output impedance analysis
  Retimer/            Retimer timing waveform analysis
figures/              Drop report images here for PROJECT_REPORT.md
```

## Running Spectre Simulations

The test benches were generated for Cadence Spectre and include absolute model paths from the original environment:

```spectre
include "/homes/user/stud/fall25/yw4576/pdk/TSMC018_teaching.scs" section=tt
ahdl_include "/tools/cadence/IC618.270/tools/dfII/samples/artist/ahdlLib/adc_8bit_ideal/veriloga/veriloga.va"
```

Update those paths before running the simulations locally.

Example:

```sh
spectre Netlist/test/INL_DNL_test_Netlist
```

Useful benches:

- `Netlist/test/INL_DNL_test_Netlist`
- `Netlist/test/Tuniing_Range_test_Netlist`
- `Netlist/test/SNDR_SFDR_test_Netlist`
- `Netlist/test/Power_test_Netlist`
- `Netlist/test/Input_Retimer_test_Netlist`
- `Netlist/test/Output_cm_test_Netlist`
- `Netlist/test/Output_diff_test_Netlist`

## MATLAB Analysis

Run each MATLAB script from its own folder so the relative CSV paths resolve.

```matlab
cd Matlab_file/Dynamic
run("SFDR_SNDR_ENOB_all.m")
```

The main analysis scripts are in the `Matlab_file/` subdirectories.
