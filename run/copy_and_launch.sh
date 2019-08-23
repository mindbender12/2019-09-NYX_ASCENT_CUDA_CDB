#!/bin/bash
cp run/8core_nyx_ascent.sh ${MEMBERWORK}/csc340/opt/nyx/src/Exec/LyA/
pushd ${MEMBERWORK}/csc340/opt/nyx/src/Exec/LyA/
bsub 8core_nyx_ascent.sh
popd
