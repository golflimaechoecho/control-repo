#!/bin/sh
# Placeholder: run on the NIM server to install patches on specified NIM client
# Additional parameters (eg: patch name/reference to install) can be added as
# parameters to task json and passed here as well (as PT_parameter)
NIMCLIENT=${PT_nimclient:?"ERROR: NIM client is required"}

# any additional validation (eg: only run on AIX, confirm this is being run from NIM server)

echo "Placeholder: run on NIM server $(uname -n) to install patches on ${NIMCLIENT}"
