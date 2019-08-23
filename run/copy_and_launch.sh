#!/bin/bash

source ./env.sh

cp run/8core_nyx_ascent.sh ${BASE_DIR}/opt/nyx/src/Exec/LyA/
pushd ${BASE_DIR}/opt/nyx/src/Exec/LyA/
bsub 8core_nyx_ascent.sh
popd
