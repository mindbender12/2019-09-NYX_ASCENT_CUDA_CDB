#!/bin/bash

source ./env.sh

cat run/8core_nyx_ascent_sampling.sh | sed "s#<basepath>#${BASE_PATH}#" > ${BASE_PATH}/opt/nyx/src/Exec/LyA/8core_nyx_ascent_sampling.sh
cat run/8core_nyx_ascent_isocontours.sh | sed "s#<basepath>#${BASE_PATH}#" > ${BASE_PATH}/opt/nyx/src/Exec/LyA/8core_nyx_ascent_isocontours.sh
pushd ${BASE_PATH}/opt/nyx/src/Exec/LyA/
bsub 8core_nyx_ascent_sampling.sh
bsub 8core_nyx_ascent_isocontours.sh
popd
