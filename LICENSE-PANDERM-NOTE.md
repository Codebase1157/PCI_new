# Third-party weights and licenses

The PCI-Stack **code** is released under the MIT License (see `LICENSE`). The pretrained
backbones it adapts are **not** redistributed in this repository and remain under their
own licenses.

## PanDerm (M₁, M₃)

PanDerm ViT-L weights are **not** included here. They are obtained from the original
authors and used under the **PanDerm research license**, per the terms of:

> S. Yan, Z. Yu, C. Primiero, et al., "A multimodal vision foundation model for clinical
> dermatology," *Nature Medicine*, 31(8):2691–2702, 2025.
> https://doi.org/10.1038/s41591-025-03747-y

Only the **LoRA adapters** we train on top of PanDerm are released (see `checkpoints/`), and
those adapters are useless without the base weights. Downloading PanDerm implies acceptance of
its research license. See `docs/data_access.md`.

## DINOv2-L (M₂)

Apache-2.0. Pulled from the official `facebookresearch/dinov2` release at setup time.

## Swin-B (M₄)

MIT. Pulled from the official `microsoft/Swin-Transformer` / `timm` release at setup time.

## MONET (concept pseudo-labels, Section 4.3 / Table S5)

Concept pseudo-labels for the 7 MONET-sourced concepts are generated with the image-text
foundation model of Kim et al. (2024), used under its released terms. We release the resulting
per-image pseudo-label manifests, not the model.

## Datasets

ISIC 2019, Derm7pt, Fitzpatrick17k-C, PAD-UFES-20, DDI and SCIN are **not** redistributed. Each is
obtained from its original host under its own license and data-use agreement. Lesion photographs
are never reproduced in this repository or in the paper figures, in accordance with the dataset
licences. See `docs/data_access.md`.
