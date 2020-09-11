#!/bin/sh
# Placeholder: run on the NIM server to create mksysb for NIM client
NIMCLIENT=${PT_nimclient:?"ERROR: NIM client is required"}
LOCATION=${PT_location:?"ERROR: location is required"}

# any additional validation (eg: only run on AIX, confirm this is being run from NIM server)

echo "Placeholder: run on NIM server $(uname -n) to create mksysb for ${NIMCLIENT}"

# Example command
# nim -o define -t mksysb -a mk_image=yes -a source=hawk -a location=/export/nim/mksysb/hawkmksysb -a server=master hawkmksysb

PLACEHOLDER_CMD="nim -o define -t mksysb -a mk_image=yes -a source=${NIMCLIENT} -a location=${LOCATION}/${NIMCLIENT}mksysb -a server=master ${NIMCLIENT}mksysb"

echo "Placeholder: mksysb example run from $(uname -n): ${PLACEHOLDER_CMD}"
