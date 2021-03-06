# simple makefile to simplify repetetive build env management tasks under posix

# caution: testing won't work on windows

PYTHON ?= python
PYTESTS ?= py.test
CTAGS ?= ctags
CODESPELL_SKIPS ?= "*.fif,*.eve,*.gz,*.tgz,*.zip,*.mat,*.stc,*.label,*.w,*.bz2,*.annot,*.sulc,*.log,*.local-copy,*.orig_avg,*.inflated_avg,*.gii,*.pyc,*.doctree,*.pickle,*.inv,*.png,*.edf,*.touch,*.thickness,*.nofix,*.volume,*.defect_borders,*.mgh,lh.*,rh.*,COR-*,FreeSurferColorLUT.txt,*.examples,.xdebug_mris_calc,bad.segments,BadChannels,*.hist,empty_file,*.orig,*.js,*.map,*.ipynb,searchindex.dat"
CODESPELL_DIRS ?= mne/ doc/ tutorials/ examples/
all: clean inplace test test-doc

clean-pyc:
	find . -name "*.pyc" | xargs rm -f

clean-so:
	find . -name "*.so" | xargs rm -f
	find . -name "*.pyd" | xargs rm -f

clean-build:
	rm -rf _build

clean-ctags:
	rm -f tags

clean-cache:
	find . -name "__pycache__" | xargs rm -rf

clean: clean-build clean-pyc clean-so clean-ctags clean-cache

in: inplace # just a shortcut
inplace:
	$(PYTHON) setup.py build_ext -i

sample_data:
	@python -c "import mne; mne.datasets.sample.data_path(verbose=True);"

testing_data:
	@python -c "import mne; mne.datasets.testing.data_path(verbose=True);"

test: in
	rm -f .coverage
	$(PYTESTS) mne

test-verbose: in
	rm -f .coverage
	$(PYTESTS) mne --verbose

test-doc: sample_data testing_data
	$(PYTESTS) --doctest-modules --doctest-ignore-import-errors --doctest-glob='*.rst' ./doc/

test-coverage: testing_data
	rm -rf coverage .coverage
	$(PYTESTS) --cov=mne --cov-report html:coverage

trailing-spaces:
	find . -name "*.py" | xargs perl -pi -e 's/[ \t]*$$//'


flake:
	@if command -v flake8 > /dev/null; then \
		echo "Running flake8"; \
		flake8 --count mne_g3d; \
	else \
		echo "flake8 not found, please install it!"; \
		exit 1; \
	fi;
	@echo "flake8 passed"

pydocstyle:
	@echo "Running pydocstyle"
	@pydocstyle

docstring:
	@echo "Running docstring tests"
	@$(PYTESTS) --doctest-modules mne/tests/test_docstring_parameters.py

pep:
	@$(MAKE) -k flake pydocstyle docstring codespell-error

build-doc-dev:
	cd doc; make clean
	cd doc; DISPLAY=:1.0 xvfb-run -n 1 -s "-screen 0 1280x1024x24 -noreset -ac +extension GLX +render" make html_dev

build-doc-stable:
	cd doc; make clean
	cd doc; DISPLAY=:1.0 xvfb-run -n 1 -s "-screen 0 1280x1024x24 -noreset -ac +extension GLX +render" make html_stable

docstyle:
	@pydocstyle
