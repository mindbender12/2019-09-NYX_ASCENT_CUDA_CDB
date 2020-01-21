#!/bin/bash
source env.sh
mkdir -p $DATA

echo 'Truncate csv for test case (head node friendly)'
head -n -5 ${BASE_PATH}/opt/nyx/src_sampling/Exec/LyA/cinema_databases/Nyx_db_sampling >/tmp/tmp_r7433e
head -n -5 ${BASE_PATH}/opt/nyx/src_isocontours/Exec/LyA/cinema_databases/Nyx_db_sampling >/tmp/tmp_r7433f
cat /tmp/tmp_r7433e > ${BASE_PATH}/opt/nyx/src_sampling/Exec/LyA/cinema_databases/Nyx_db_sampling
cat /tmp/tmp_r7433f > ${BASE_PATH}/opt/nyx/src_isocontours/Exec/LyA/cinema_databases/Nyx_db_isocontours
rm /tmp/tmp_r7433e
rm /tmp/tmp_r7433f

echo 'Package the db tarball for xfer and validation'
mkdir ${DATA}/cinema_databases
cp -R ${BASE_PATH}/opt/nyx/src_sampling/Exec/LyA/cinema_databases/Nyx_db_sampling ${DATA}/cinema_databases/Nyx_db_sampling
cp -R ${BASE_PATH}/opt/nyx/src_isocontours/Exec/LyA/cinema_databases/Nyx_db_contour ${DATA}/cinema_databases/Nyx_db_contour
tar -cvJf ${DATA}/2019-09-NYC_ASCENT_CUDA_CDB_COMPARE.tar.xz ${DATA}/cinema_databases
echo ===========================================================
echo Cinema database tarball created:
echo  ${DATA}/2019-09-NYC_ASCENT_CUDA_CDB_COMPARE.tar.xz
echo
echo Please transfer this to a computer, unpack the tarball,
echo and view cinema databases with viewer of your choice.
echo
echo ===========================================================
