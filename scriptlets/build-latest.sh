#!/bin/bash -e

function find_latest() {
    VARIANT_FOLDER="$2"
    if [[ "$1" == arm* && "$2" == 'base' ]]; then
        VARIANT_FOLDER='generic'
    fi

    cat << 'EOF' > t.pl
use strict;
my $regex = qr/aosc-os_%var%_\d{8}(?>_amd64)?\.tar\.(?>gz|xz)/mp;
my @matches = <STDIN> =~ /$regex/g;
foreach my $match (@matches) {print "$match\n"};
EOF

    sed -i "s/%var%/$2/g" t.pl

    TARBALL_NAME=$(curl -s "https://releases.aosc.io/os-$1/${VARIANT_FOLDER}/" | perl -n t.pl | sort | tail -n1)
    if [[ "x${TARBALL_NAME}" == 'x' ]]; then
    echo 'Cannot find latest tarball'
    exit 1
    fi

    export TARBALL_URL="https://repo.aosc.io/aosc-os/os-$1/${VARIANT_FOLDER}/${TARBALL_NAME}"
    rm -f t.pl
}

COMPONENT="${2/aosc-os/}"
COMPONENT="${COMPONENT#"-"}"
find_latest "$1" "${COMPONENT:-base}"
export TAGNAME="aosc/$2"
./scriptlets/gen_dockerfile.sh
