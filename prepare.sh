#!/usr/bin/env bash

KEYNAME="worker_id_rsa"

rm ${KEYNAME}*
ssh-keygen -f "./$KEYNAME" -b 4096 -N ''
