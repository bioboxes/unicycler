#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

fetch(){
	mkdir -p /usr/local/$2
	TMP=$(mktemp)
	wget $1 --quiet --output-document ${TMP}
	tar xf ${TMP} --directory /usr/local/$2 --strip-components=1
	rm ${TMP}
}


NON_ESSENTIAL_BUILD="
	ca-certificates
	g++
	lbzip2
	make
	patch
	python3-pip
	python3-setuptools
	unzip
	wget
	zlibc"

ESSENTIAL_BUILD="
	libncurses5-dev
	openjdk-7-jre-headless
	pigz
	python${PYTHON_VERSION}-minimal
	python3-pkg-resources
	zlib1g-dev"

# Build dependencies
apt-get update --yes
apt-get install --yes --no-install-recommends ${NON_ESSENTIAL_BUILD} ${ESSENTIAL_BUILD}

export PATH=$PATH:/usr/local/bin/install

# Install individual tools
bwa.sh
bowtie2.sh
pilon.sh
samtools.sh
spades.sh
unicycler.sh

# Clean up dependencies
apt-get autoremove --purge --yes ${NON_ESSENTIAL_BUILD}
apt-get clean

# Install required files
apt-get install --yes --no-install-recommends ${ESSENTIAL_BUILD}

# Spades requires a `python` executable
ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python

rm -rf /var/lib/apt/lists/*

# Remove all no-longer-required build artefacts
EXTENSIONS=("pyc" "c" "cc" "cpp" "h" "o" "pdf")
for EXT in "${EXTENSIONS[@]}"
do
	find /usr/local -name "*.$EXT" -delete
done
