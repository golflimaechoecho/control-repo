#!/bin/sh
# Placeholder: run on the NIM server to create mksysb for NIM client
NIMCLIENT=${PT_nimclient:?"ERROR: NIM client is required"}
MKSYSB_LOCATION=${PT_mksysb_location:?"ERROR: mksysb location is required"}
SPOT_LOCATION=${PT_spot_location:?"ERROR: spot location is required"}

# Pass shortname not FQDN
NIMCLIENT_SHORTNAME=${NIMCLIENT%%.*}

NIMSERVER=$(uname -n)
# any additional validation (eg: only run on AIX, confirm this is being run from NIM server)

echo "Placeholder: run on NIM server ${NIMSERVER} to create mksysb for ${NIMCLIENT}"

# Example mksysb command
# nim -o define -t mksysb -a mk_image=yes -a source=hawk -a location=/export/nim/mksysb/hawkmksysb -a server=master hawkmksysb

PLACEHOLDER_MKSYSB_CMD="nim -o define -t mksysb -a mk_image=yes -a source=${NIMCLIENT_SHORTNAME} -a location=${MKSYSB_LOCATION}/${NIMCLIENT_SHORTNAME}mksysb -a server=master ${NIMCLIENT_SHORTNAME}mksysb"

echo "Placeholder: mksysb example run from ${NIMSERVER}: ${PLACEHOLDER_MKSYSB_CMD}"

# Example SPOT command
# nim -o define -t spot -a server=master -a source=hawkmksysb -a location=/export/nim/spot/hawkspot hawkspot

PLACEHOLDER_SPOT_CMD="nim -o define -t spot -a server=master -a source=${NIMCLIENT_SHORTNAME}mksysb -a location=${SPOT_LOCATION}/${NIMCLIENT_SHORTNAME}spot ${NIMCLIENT_SHORTNAME}spot"

echo "Placeholder: spot example run from ${NIMSERVER}: ${PLACEHOLDER_SPOT_CMD}"
