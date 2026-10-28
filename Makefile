.PHONY: help install test demo lint tables clean
FOLD ?= isic2019
CONFIG ?= configs/default.yaml

help:
	@echo "PCI-Stack make targets:"
	@echo "  install   editable install + dev deps"
	@echo "  test      run unit tests (self-contained numerics)"
	@echo "  demo      synthetic end-to-end smoke test (no weights/data)"
	@echo "  tables    rebuild paper tables from results/"
	@echo "  lint      ruff check"
	@echo "  pipeline  full LODO pipeline for FOLD=$(FOLD)"

install:
	pip install -e .
	pip install pytest ruff

test:
	pytest -q

demo:
	python scripts/demo_synthetic.py

tables:
	python scripts/08_reproduce_tables.py

lint:
	ruff check pci_stack scripts tests

pipeline:
	python scripts/00_prepare_data.py        --config $(CONFIG)
	python scripts/01_estimate_tone.py       --config $(CONFIG)
	python scripts/02_make_splits.py         --config $(CONFIG)
	python scripts/03_train_learners.py      --config $(CONFIG) --fold $(FOLD)
	python scripts/04_train_meta.py          --config $(CONFIG) --fold $(FOLD)
	python scripts/05_calibrate_conformal.py --config $(CONFIG) --fold $(FOLD)
	python scripts/06_evaluate.py            --config $(CONFIG)

clean:
	rm -rf build dist *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
