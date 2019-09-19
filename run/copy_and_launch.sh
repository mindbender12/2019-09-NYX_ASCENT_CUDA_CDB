#!/bin/bash

source ./env.sh

cat run/8core_nyx_ascent.sh | sed "s#<basepath>#${BASE_PATH}#" > ${BASE_PATH}/opt/nyx/src/Exec/LyA/8core_nyx_ascent.sh
pushd ${BASE_PATH}/opt/nyx/src/Exec/LyA/
bsub 8core_nyx_ascent.sh
popd
