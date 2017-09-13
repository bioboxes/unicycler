#!/bin/bash

cd $(mktemp -d)
wget \
	--quiet \
	https://downloads.sourceforge.net/project/bowtie-bio/bowtie2/${BOWTIE_VERSION}/bowtie2-${BOWTIE_VERSION}-linux-x86_64.zip
unzip bowtie2-${BOWTIE_VERSION}-linux-x86_64.zip
mv bowtie2-${BOWTIE_VERSION}/bowtie2* /usr/local/bin
rm -rf bowtie2-${BOWTIE_VERSION}
