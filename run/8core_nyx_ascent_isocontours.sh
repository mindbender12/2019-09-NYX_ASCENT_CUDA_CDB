#!/bin/bash

#BSUB -J nyx_in_situ
#BSUB -nnodes 8
#BSUB -P CSC340
#BSUB -W 00:07

module load gcc/5.4.0
module load spectrum-mpi
module load hdf5/1.10.3
module load cuda/10.1.105

jsrun -n 8 -g 1  <basepath>/opt/nyx/src_isocontours/Exec/LyA/Nyx3d.gnu.PROF.MPI.OMP.ex inputs
