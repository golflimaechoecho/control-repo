#!/bin/sh
LOCKFILE=/var/run/pe_patch_fact_generation.lock
[ -f ${LOCKFILE} ] && {
  result=true
} || {
  result=false
}
echo "{\"pe_patch_locked\": $result}"
