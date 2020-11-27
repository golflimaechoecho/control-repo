#!/bin/bash

# Set variables
certname=$PT_certname
[ ${PT_certname:?'ERROR: certname must be provided'} ]

PUPPET_PATH=/opt/puppetlabs/bin

# Declare functions
check_node_exists()
{
  ${PUPPET_PATH}/puppetserver ca list --certname ${certname}
  if [ $? != 0 ]
  then
    echo Error: Node $node does not exist in PE node list
    exit 1
  fi
}

confirm_node_removal()
{
  ${PUPPET_PATH}/puppetserver ca list --certname ${certname}
  if [ $? != 0 ]
  then
    echo Success: Node $node purged
    exit 0
  fi
}


# This is only valid when run on PE primary server
PE_SERVER_VERSION=$(/usr/local/bin/facter -p pe_server_version)
if [ -n "${PE_SERVER_VERSION}" ]
then
  check_node_exists
  ${PUPPET_PATH}/puppet node purge ${certname}
  confirm_node_removal
else
  echo 'Error: This task must run on the PE primary server'
  exit 1
fi
