#!/usr/bin/env bash

KEYNAME="control-node-key"

rm ${KEYNAME}*
ssh-keygen -f "./$KEYNAME" -b 4096 -N ''
