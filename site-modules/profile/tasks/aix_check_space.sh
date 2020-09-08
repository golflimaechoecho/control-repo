#!/bin/sh
# Check space on AIX
# For argument's sake, assume need minimum 1GB (1048576K) free
MINSPACE=${PT_minspace:-1048576}

echo "Run df -k <filesystem> and any other checks to confirm sufficient space"
