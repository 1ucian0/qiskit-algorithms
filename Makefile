# This code is part of a Qiskit project.
#
# (C) Copyright IBM 2021, 2023.
#
# This code is licensed under the Apache License, Version 2.0. You may
# obtain a copy of this license in the LICENSE.txt file in the root directory
# of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
#
# Any modifications or derivative works of this code must retain this
# copyright notice, and modified files need to carry a notice indicating
# that they have been altered from the originals.

OS := $(shell uname -s)

ifeq ($(OS), Linux)
  NPROCS := $(shell grep -c ^processor /proc/cpuinfo)
else ifeq ($(OS), Darwin)
  NPROCS := 2
else
  NPROCS := 0
endif # $(OS)

ifeq ($(NPROCS), 2)
	CONCURRENCY := 2
else ifeq ($(NPROCS), 1)
	CONCURRENCY := 1
else ifeq ($(NPROCS), 3)
	CONCURRENCY := 3
else ifeq ($(NPROCS), 0)
	CONCURRENCY := 0
else
	CONCURRENCY := $(shell echo "$(NPROCS) 2" | awk '{printf "%.0f", $$1 / $$2}')
endif

# You can set this variable from the command line.
SPHINXOPTS    =

.PHONY: lint style black test test_ci spell copyright html doctest clean_sphinx coverage clean

all_check: spell style lint copyright clean_sphinx html doctest

lint:
	pylint -rn qiskit_algorithms test tools
	python tools/verify_headers.py qiskit_algorithms test tools

style:
	black --check qiskit_algorithms test tools

black:
	black qiskit_algorithms test tools

test:
	python -m unittest discover -v test

test_ci:
	echo "Detected $(NPROCS) CPUs running with $(CONCURRENCY) workers"
	stestr run --concurrency $(CONCURRENCY)

spell:
	pylint -rn --disable=all --enable=spelling --spelling-dict=en_US --spelling-private-dict-file=.pylintdict qiskit_algorithms test tools
	sphinx-build -M spelling docs docs/_build -W -T --keep-going $(SPHINXOPTS)

copyright:
	python tools/check_copyright.py

html:
	sphinx-build -M html docs docs/_build -W -T --keep-going $(SPHINXOPTS)

doctest:
	sphinx-build -M doctest docs docs/_build -W -T --keep-going $(SPHINXOPTS)

clean_sphinx:
	make -C docs clean

coverage:
	coverage3 run --source qiskit_algorithms -m unittest discover -s test -q
	coverage3 report

coverage_erase:
	coverage erase

clean: coverage_erase;
