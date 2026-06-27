# Project Report Figures

Put the project report images in this `figures/` folder using the filenames below. `DAC_Project_Report.md` already references these paths, so each picture will appear in the report after the matching image file is added.

Supported formats are usually `png`, `jpg`, `jpeg`, or `svg`, but the report currently links to `.png` files. Rename exported images to these exact names or update the links in `DAC_Project_Report.md`.

| Figure | Filename | Caption |
| --- | --- | --- |
| Fig. 1 | `fig01-top-level-schematic.png` | Top-level schematic of the 8-bit DAC |
| Fig. 2 | `fig02-bit-cell.png` | Single bit DAC cell tuned by a 6-bit trim DAC |
| Fig. 3 | `fig03-trim-dac-cell.png` | Single-bit trim DAC cell |
| Fig. 4 | `fig04-dac-core.png` | Complete 8-bit DAC core |
| Fig. 5 | `fig05-retimer-cell.png` | Single-bit retimer cell |
| Fig. 6 | `fig06-nand-gate.png` | NAND gate schematic |
| Fig. 7 | `fig07-input-retimer.png` | Complete 8-bit input retimer block |
| Fig. 8 | `fig08-bias-generator.png` | Bias generator |
| Fig. 9 | `fig09-output-impedance-code.png` | Low-frequency output impedance vs. input code |
| Fig. 10 | `fig10-output-impedance-frequency.png` | Output impedance vs. frequency for selected codes |
| Fig. 11 | `fig11-retimer-waveforms.png` | Retimer waveforms |
| Fig. 12 | `fig12-retimer-delay.png` | Zoomed retimer transition and delay |
| Fig. 13 | `fig13-tuning-range.png` | Analog weight tuning range |
| Fig. 14 | `fig14-spectrum-low-frequency.png` | Output spectrum at low input frequency |
| Fig. 15 | `fig15-spectrum-near-nyquist.png` | Output spectrum near Nyquist |
| Fig. 16 | `fig16-sfdr-vs-frequency.png` | SFDR vs. input frequency |
| Fig. 17 | `fig17-sndr-vs-frequency.png` | SNDR vs. input frequency |

## Adding a New Figure

1. Add the image file to this folder.
2. Insert a Markdown image link in `DAC_Project_Report.md`:

```md
![Caption text](figures/my-new-figure.png)
```

3. Add the filename to the table above if you want to keep this checklist complete.
