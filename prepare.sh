#!/usr/bin/env bash

KEYNAME="id_rsa"

rm ${KEYNAME}*
ssh-keygen -f "./$KEYNAME" -b 4096 -N ''
