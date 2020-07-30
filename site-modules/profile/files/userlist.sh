#!/bin/bash
printf "userlist: [$(getent passwd | awk -v q="'" -F: '{print q $1 q ","}' |xargs)]\n"
