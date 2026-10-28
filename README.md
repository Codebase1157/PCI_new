<div align="center">

# PCI-Stack

### Invariance-Induced Diversity in Stacked Ensembles
**Physics-Guided Counterfactual Meta-Fusion for Fair and Generalizable Skin Lesion Diagnosis**

Amit Kumar Arora · Amanpreet Kaur

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/)
[![DOI](https://img.shields.io/badge/Zenodo-10.5281%2Fzenodo.XXXXXXX-blue.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)

</div>

---

PCI-Stack is a **stacked ensemble whose base learners are made diverse by construction**. Each
learner is trained under a distinct *physics-guided counterfactual-invariance contract*; a
counterfactual-consistent meta-learner fuses their out-of-fold predictions with
instance-dependent gating; and a shift-aware, group-conditional conformal layer supplies
equalized prediction-set coverage with an explicit abstention rule. A five-stage explanation
audit closes the loop.

This repository is the official release accompanying the paper. It contains everything named in
Section 4.7 of the manuscript:

> *Code, data splits, counterfactual generators, pretrained adapters, configuration files and the
> explanation-audit package.*

The two source documents are included under [`paper/`](paper/) for reference.

## The five tiers

| Tier | Component | Module | Key equations |
|------|-----------|--------|---------------|
| 1 | Physics-guided counterfactual engine | [`pci_stack/generators`](pci_stack/generators) | (3)–(8) |
| 2 | Counterfactual-diverse learner zoo (M₁–M₄, LoRA) | [`pci_stack/models`](pci_stack/models), [`pci_stack/losses`](pci_stack/losses) | (9)–(13) |
| 3 | Counterfactual-consistent stacked meta-fusion | [`pci_stack/fusion`](pci_stack/fusion) | (14)–(20) |
| 4 | Shift-aware group-conditional conformal layer | [`pci_stack/conformal`](pci_stack/conformal) | (21)–(25) |
| 5 | Explanation-audit package | [`pci_stack/audit`](pci_stack/audit) | (26)–(30) |

The four base learners and their invariance contracts (Section 4.3):

| Learner | Backbone | Contract | Mechanism |
|---------|----------|----------|-----------|
| **M₁** | PanDerm ViT-L | tone invariance | melanin-shift counterfactual consistency + HSIC |
| **M₂** | DINOv2-L | acquisition invariance | Fourier/photometric counterfactual consistency + HSIC |
| **M₃** | PanDerm ViT-L¹ | concept invariance | 22-concept clinical layer + consistency |
| **M₄** | Swin-B | joint invariance | gradient reversal against a nuisance discriminator |

¹ M₁ and M₃ share a single frozen PanDerm ViT-L backbone pass (three backbone evaluations per
image, not four — see Table S8).

## Install

```bash
git clone https://github.com/pci-stack/pci-stack.git
cd pci-stack
python -m venv .venv && source .venv/bin/activate
pip install -e .            # or:  pip install -r requirements.txt
```

The physics engine, loss functions, meta-fusion, conformal layer and audit package run on CPU
with only `numpy`/`scipy`/`torch`. Training the learner zoo needs a 24 GB accelerator (peak
17.8 GB observed) and the backbone weights described in [`docs/data_access.md`](docs/data_access.md).

## Quick start

Every stage is a numbered script. The full leave-one-domain-out (LODO) pipeline is:

```bash
# 0. harmonize the six datasets into the binary task (Table 1, S4)
python scripts/00_prepare_data.py       --config configs/default.yaml

# 1. label-free skin-tone (ITA) estimation (Section 3.2)
python scripts/01_estimate_tone.py      --config configs/default.yaml

# 2. patient-level LODO splits: 70/15/15 learner / level-1 / calibration (Section 3.3)
python scripts/02_make_splits.py        --config configs/default.yaml

# 3. stage-1: train the four counterfactual-diverse learners
python scripts/03_train_learners.py     --config configs/default.yaml --fold isic2019

# 4. stage-2: out-of-fold level-1 features + counterfactual-consistent meta-fusion
python scripts/04_train_meta.py         --config configs/default.yaml --fold isic2019

# 5. shift-aware group-conditional conformal calibration
python scripts/05_calibrate_conformal.py --config configs/default.yaml --fold isic2019

# 6. evaluate (LODO folds + the two external sets, one pass)
python scripts/06_evaluate.py           --config configs/default.yaml

# 7. explanation audit (AAI, CAS, insertion/deletion, surrogate)
python scripts/07_run_audit.py          --config configs/default.yaml

# 8. rebuild the paper tables from results/
python scripts/08_reproduce_tables.py
```



```bash
python scripts/demo_synthetic.py
```

## Reproducibility

- **Primary endpoint** (fixed before any result was inspected): worst-group AUROC on DDI.
- **Protocol**: LODO over four training sources; **DDI** and **SCIN** are external-only and are
  evaluated exactly once, after every design decision is frozen.
- **Determinism**: all stages are seeded (`pci_stack.utils.seed`); five seeds for PCI-Stack and
  the three strongest baselines, three for the rest.
- Every hyper-parameter in Supplementary Table S1 lives in [`configs/`](configs/); nothing is
  hard-coded.

See [`docs/reproduce.md`](docs/reproduce.md) for the exact commands that regenerate Tables 2–7,
and [`docs/data_access.md`](docs/data_access.md) for how to obtain the six public datasets and the
backbone weights (none are redistributed here).

## Repository layout

```
pci-stack/
├── configs/            # all hyper-parameters (Table S1), one YAML per concern
├── pci_stack/          # the library
│   ├── generators/     # Tier 1 — physics-guided counterfactual engine
│   ├── models/         # Tier 2 — backbones, LoRA, GRL, the learner zoo
│   ├── losses/         # eq (9)–(13), (18)–(20)
│   ├── fusion/         # Tier 3 — out-of-fold stacking + gated meta-fusion
│   ├── conformal/      # Tier 4 — Mondrian + shift reweighting + abstention
│   ├── audit/          # Tier 5 — Grad-CAM, LIME surrogate, AAI, CAS, faithfulness
│   ├── data/           # harmonization, label map, tone estimation, splits, concepts
│   └── engine/         # stage-1/2 trainers, LODO driver, evaluation
├── scripts/            # numbered, runnable pipeline (00–08) + demo
├── splits/             # LODO split manifests + schema (+ example rows)
├── checkpoints/        # adapter MANIFEST + loader (weights fetched, not vendored)
├── logs/               # example training/calibration logs
├── results/tables/     # CSV reproductions of Tables 2–7
├── tests/              # unit tests for the self-contained numerics
├── docs/               # reproduce.md, data_access.md
└── paper/              # manuscript + supplementary material
```

## Licensing

All code and configuration are released under the [MIT License](LICENSE). Pretrained **PanDerm**
weights are **not** redistributed here; they are obtained from the original authors and used under
the PanDerm research license — see [`LICENSE-PANDERM-NOTE.md`](LICENSE-PANDERM-NOTE.md). DINOv2 and
Swin weights are pulled from their official sources at setup time.

## Citation

If you use PCI-Stack, please cite the paper (see [`CITATION.cff`](CITATION.cff)):

```bibtex
@article{arora_pcistack,
  title   = {Invariance-Induced Diversity in Stacked Ensembles: Physics-Guided
             Counterfactual Meta-Fusion for Fair and Generalizable Skin Lesion Diagnosis},
  author  = {Arora, Amit Kumar and Kaur, Amanpreet},
  journal = {KSII Transactions on Internet and Information Systems},
  year    = {20XX},
  doi     = {10.3837/tiis.20XX.XX.0XX}
}
```


