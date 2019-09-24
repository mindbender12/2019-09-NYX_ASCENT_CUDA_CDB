#!/bin/bash
source env.sh
mkdir -p $DATA

echo 'Truncate csv for test case (head node friendly)'
head -n -5 ${BASE_PATH}/opt/nyx/src/Exec/LyA/cinema_databases/Nyx_db_sampling >/tmp/tmp_r7433e
cat /tmp/tmp_r7433e > ${BASE_PATH}/opt/nyx/src/Exec/LyA/cinema_databases/Nyx_db_sampling
rm /tmp/tmp_r7433e

echo 'This workflow needs to start from its own base directory'
pushd submodules/cinema_workflows/2019-09_ASCENT
./run ${BASE_PATH}/opt/nyx/src/Exec/LyA/cinema_databases/Nyx_db_sampling
echo 'Move the viewer to the data'
mv cinema/ explore.html ${BASE_PATH}/opt/nyx/src/Exec/LyA/cinema_databases/
popd

echo 'Package the viewer+db tarball for xfer and validation'
pushd ${BASE_PATH}/opt/nyx/src/Exec/LyA/
tar -cvJf ${DATA}/cinema_viewer.tar.xz cinema_databases/
echo ===========================================================
echo Cinema database tarball created:
echo  ${DATA}/cinema_viewer.tar.xz
echo
echo Please transfer this to a computer with Firefox, unpack
echo the tarball, and open explore.html.
echo 
echo ===========================================================
