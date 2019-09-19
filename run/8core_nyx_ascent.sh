#!/bin/bash

#BSUB -J nyx_in_situ
#BSUB -nnodes 8
#BSUB -P CSC340
#BSUB -W 00:03

module load gcc/5.4.0
module load python/2.7.15-anaconda2-5.3.0
module load hdf5/1.10.3

jsrun -n 8 <basepath>/opt/nyx/src/Exec/LyA/Nyx3d.gnu.PROF.MPI.OMP.ex inputs
