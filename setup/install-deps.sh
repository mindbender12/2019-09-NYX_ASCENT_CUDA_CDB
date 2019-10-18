#!/bin/bash -l
# The "-l" arg uses your .bashrc scripts. Use this as an opportunity
# to source your environment modules for your platform.
#
# Be aware of Anaconda installations you may have.
###############################################################################

if [[ $(hostname -f | grep summit) == "" ]]; then echo "Pipeline fail: Must run on Summit (login node ok)" >&2; exit 1; fi

# Exit immediately if program executes with non-zero error status
set -e

source ./env.sh
# Start with fresh compile
echo Removing previous installations...
rm -rf $BASE_PATH $DATA 
# Load modules available on summit. 8/14/2019
modules=( hsi/5.0.2.p5
          lsf-tools/2.0
          DefApps
          gcc/5.4.0
          xalt/1.1.3
          darshan-runtime/3.1.7
          cmake/3.9.2
          cuda/10.1.105
          hdf5/1.10.3 
          gcc/5.4.0
          spectrum-mpi
        )
for module in ${modules[@]}; do
  echo Loading module $module: BEGIN;
  module load $module
  echo Loaded module $module: SUCCESS;
done;


# This changes if repo contains multiple experiment subdirectories
# Prefer env variable over PWD
BASE_PATH="${BASE_PATH:-$PWD}"

# Prepare your environment for Conduit, Ascent, Nyx builds.
# Conduit is standalone. Ascent is dependency of Nyx.
OPT_PATH=${BASE_PATH}/opt

# Need to sort out how to check for previous installations
# just delete and recreate it for now.
rm -rf ${OPT_PATH}

mkdir -p ${OPT_PATH}
export LDFLAGS='-pthread -lpthread'

echo Conduit env setup: BEGIN
git clone --recursive https://github.com/LLNL/conduit.git ${OPT_PATH}/conduit/src
# conduit paths
CONDUIT_BUILD=${OPT_PATH}/conduit/src/build
mkdir -p ${CONDUIT_BUILD}
CONDUIT_INSTALL=${OPT_PATH}/conduit/0c30223
mkdir -p ${CONDUIT_INSTALL}
pushd ${OPT_PATH}/conduit/src/
git checkout 0c30223cbf1ea06bc6f327a6a6a50966846350bb
git submodule init
git submodule update
popd
echo Conduit env setup: SUCCESS

# Source clone
echo Conduit compile: BEGIN
# Compile
pushd ${CONDUIT_BUILD}
#cmake -DCMAKE_C_COMPILER=/sw/summit/gcc/5.4.0/bin/gcc -DCMAKE_CXX_COMPILER=/sw/summit/gcc/5.4.0/bin/g++ -DCMAKE_BUILD_TYPE=Release -DENABLE_MPI=ON -DENABLE_OPENMP=OFF ../src
echo 'set(HDF5_DIR "/autofs/nccs-svm1_sw/summit/.swci/1-compute/opt/spack/20180914/linux-rhel7-ppc64le/xl-16.1.1-3/hdf5-1.10.3-lkiyvnhwujxwna67ldnlzslvoqgjavyr" CACHE PATH "")' > ../host-configs/summit.cmake
cmake -DBUILD_SHARED_LIBS=ON  -DCMAKE_C_COMPILER=/sw/summit/gcc/5.4.0/bin/gcc -DCMAKE_CXX_COMPILER=/sw/summit/gcc/5.4.0/bin/g++ -DCMAKE_BUILD_TYPE=Release -DENABLE_FORTRAN=ON ../src
# Fortran object needs to be built first, error in CMake logic prevents one line build
cmake -DCMAKE_C_COMPILER=/sw/summit/gcc/5.4.0/bin/gcc -DCMAKE_CXX_COMPILER=/sw/summit/gcc/5.4.0/bin/g++ -DCMAKE_BUILD_TYPE=Release -DENABLE_MPI=ON -DENABLE_OPENMP=OFF -DCMAKE_INSTALL_PREFIX=${CONDUIT_INSTALL} -DENABLE_PYTHON=OFF -C ../host-configs/summit.cmake ../src
echo Conduit compile: SUCCESS
echo Conduit install: BEGIN
make install -j 1
popd
echo Conduit install: SUCCESS
echo Conduit manual config generation: BEGIN
echo "CONDUIT_DIR = ${CONDUIT_INSTALL}

CONDUIT_SILO_DIR  =
CONDUIT_HDF5_DIR  =
CONDUIT_ZLIB_DIR  =
CONDUIT_ADIOS_DIR =

CONDUIT_EXTRA_LIB_FLAGS =  -ldl -lrt -pthread

CONDUIT_LINK_RPATH = -Wl,-rpath,\$(CONDUIT_DIR)/lib

# two steps are used b/c there are commas in the linker commands
# which will undermine parsing of the makefile
CONDUIT_SILO_RPATH_FLAGS_VALUE  = -Wl,-rpath,\$(CONDUIT_SILO_DIR)/lib
CONDUIT_HDF5_RPATH_FLAGS_VALUE  = -Wl,-rpath,\$(CONDUIT_HDF5_DIR)/lib
CONDUIT_ZLIB_RPATH_FLAGS_VALUE  = -Wl,-rpath,\$(CONDUIT_ZLIB_DIR)/lib
CONDUIT_ADIOS_RPATH_FLAGS_VALUE = -Wl,-rpath,\$(CONDUIT_ADIOS_DIR)/lib

CONDUIT_LINK_RPATH += \$(if \$(CONDUIT_SILO_DIR), \$(CONDUIT_SILO_RPATH_FLAGS_VALUE))
CONDUIT_LINK_RPATH += \$(if \$(CONDUIT_HDF5_DIR), \$(CONDUIT_HDF5_RPATH_FLAGS_VALUE))
CONDUIT_LINK_RPATH += \$(if \$(CONDUIT_ZLIB_DIR), \$(CONDUIT_ZLIB_RPATH_FLAGS_VALUE))
CONDUIT_LINK_RPATH += \$(if \$(CONDUIT_ADIOS_DIR), \$(CONDUIT_ADIOS_RPATH_FLAGS_VALUE))


#################
# Include Flags
#################
CONDUIT_INCLUDE_FLAGS  = -I \$(CONDUIT_DIR)/include/conduit
CONDUIT_INCLUDE_FLAGS += \$(if \$(CONDUIT_ADIOS_DIR),-I\$(CONDUIT_ADIOS_DIR)/include)
CONDUIT_INCLUDE_FLAGS += \$(if \$(CONDUIT_SILO_DIR),-I\$(CONDUIT_SILO_DIR)/include)
CONDUIT_INCLUDE_FLAGS += \$(if \$(CONDUIT_HDF5_DIR),-I\$(CONDUIT_HDF5_DIR)/include)

#################
# Linking Flags
#################

###################################################
# ADIOS
#################
CONDUIT_ADIOS_LIB_FLAGS = \$(if \$(CONDUIT_ADIOS_DIR),)
CONDUIT_ADIOS_MPI_LIB_FLAGS = \$(if \$(CONDUIT_ADIOS_DIR),)


##########
# Silo
##########
CONDUIT_SILO_LIB_FLAGS = \$(if \$(CONDUIT_SILO_DIR),-L \$(CONDUIT_SILO_DIR)/lib -lsiloh5)


##########
# HDF5
##########
CONDUIT_HDF5_LIB_FLAGS = \$(if \$(CONDUIT_HDF5_DIR),-L \$(CONDUIT_HDF5_DIR)/lib -lhdf5)


##########
# ZLIB
##########
CONDUIT_ZLIB_LIB_FLAGS = \$(if \$(CONDUIT_ZLIB_DIR),-L \$(CONDUIT_ZLIB_DIR)/lib -lz)



##########
# Conduit
##########
# All conduit libs, without MPI
CONDUIT_LIB_FLAGS = -L \$(CONDUIT_DIR)/lib \
                    -lconduit_blueprint \
                    -lconduit_relay \
                    -lconduit \$(CONDUIT_ADIOS_LIB_FLAGS) \$(CONDUIT_SILO_LIB_FLAGS) \$(CONDUIT_HDF5_LIB_FLAGS) \$(CONDUIT_ZLIB_LIB_FLAGS) \$(CONDUIT_EXTRA_LIB_FLAGS)

# All conduit libs, with MPI
CONDUIT_MPI_LIB_FLAGS = -L \$(CONDUIT_DIR)/lib \
                        -lconduit_relay_mpi_io \
                        -lconduit_relay_mpi \
                        -lconduit_blueprint \
                        -lconduit_relay \
                        -lconduit \$(CONDUIT_ADIOS_MPI_LIB_FLAGS) \$(CONDUIT_SILO_LIB_FLAGS) \$(CONDUIT_HDF5_LIB_FLAGS) \$(CONDUIT_ZLIB_LIB_FLAGS) \$(CONDUIT_EXTRA_LIB_FLAGS)" > ${CONDUIT_INSTALL}/share/conduit/conduit_config.mk

echo Conduit manual config generation: END


echo VTK-m env setup: BEGIN
git clone --recursive  https://gitlab.kitware.com/vtk/vtk-m.git ${OPT_PATH}/vtkm/src
pushd ${OPT_PATH}/vtkm/src/
git checkout cbe9b261
popd
# vtkm paths
VTKM_BUILD=${OPT_PATH}/vtkm/src/build
mkdir -p ${VTKM_BUILD}
VTKM_INSTALL=${OPT_PATH}/vtkm/cbe9b261
mkdir -p ${VTKM_INSTALL}
echo VTK-m env setup: SUCCESS
echo VTK-m compile: BEGIN
pushd ${VTKM_BUILD}
cmake -DCMAKE_C_COMPILER=/sw/summit/gcc/5.4.0/bin/gcc -DCMAKE_CXX_COMPILER=/sw/summit/gcc/5.4.0/bin/g++ -DCMAKE_BUILD_TYPE=Release -DVTKm_USE_64BIT_IDS=OFF -DVTKm_USE_DOUBLE_PRECISION=ON -DVTKm_ENABLE_OPENMP=OFF -DVTKm_ENABLE_MPI=OFF -DVTKm_ENABLE_CUDA=ON -DCMAKE_INSTALL_PREFIX=${VTKM_INSTALL} ../
cmake -DCMAKE_C_COMPILER=/sw/summit/gcc/5.4.0/bin/gcc -DCMAKE_CXX_COMPILER=/sw/summit/gcc/5.4.0/bin/g++ -DCMAKE_BUILD_TYPE=Release -DVTKm_USE_64BIT_IDS=OFF -DVTKm_USE_DOUBLE_PRECISION=ON -DVTKm_ENABLE_OPENMP=OFF -DVTKm_ENABLE_MPI=OFF -DVTKm_ENABLE_CUDA=ON -DVTKm_CUDA_Architecture=volta -DVTKm_ENABLE_TESTING=OFF -DCMAKE_INSTALL_PREFIX=${VTKM_INSTALL} ../
echo VTK-m compile: SUCCESS
echo VTK-m install: BEGIN
make install -j 50
popd
echo VTK-m install: SUCCESS

echo VTK-h env setup: BEGIN
git clone --recursive https://github.com/Alpine-DAV/vtk-h.git ${OPT_PATH}/vtkh/src
pushd ${OPT_PATH}/vtkh/src
git checkout  23d861a1266be00bbd1137a48aa820ed69a6cfd7
git submodule init
git submodule update
popd
# vtkh paths
VTKH_BUILD=${OPT_PATH}/vtkh/src/build
mkdir -p ${VTKH_BUILD}
VTKH_INSTALL=${OPT_PATH}/vtkh/23d861a
mkdir -p ${VTKH_INSTALL}
echo VTK-h env setup: SUCCESS
echo VTK-h compile: BEGIN
pushd ${VTKH_BUILD}
cmake -DCMAKE_C_COMPILER=/sw/summit/gcc/5.4.0/bin/gcc -DCMAKE_CXX_COMPILER=/sw/summit/gcc/5.4.0/bin/g++ -DVTKM_DIR=${VTKM_INSTALL}  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${VTKH_INSTALL} -DENABLE_OPENMP=OFF -DENABLE_CUDA=ON -DENABLE_MPI=ON ../src
cmake -DCMAKE_C_COMPILER=/sw/summit/gcc/5.4.0/bin/gcc -DCMAKE_CXX_COMPILER=/sw/summit/gcc/5.4.0/bin/g++ -DVTKM_DIR=${VTKM_INSTALL}  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${VTKH_INSTALL} -DENABLE_OPENMP=OFF -DVTKm_CUDA_Architecture=volta -DENABLE_MPI=ON ../src
make install -j 50
popd
echo VTK-h compile: SUCCESS

echo Ascent env setup: BEGIN
git clone --recursive https://github.com/Alpine-DAV/ascent.git ${OPT_PATH}/ascent/src
pushd ${OPT_PATH}/ascent/src
git checkout 0bb51d62d72bebf7d3d2c3a16933b86ac7d2364b
git submodule init
git submodule update
popd
# ascent paths
ASCENT_BUILD=${OPT_PATH}/ascent/src/build
mkdir -p ${ASCENT_BUILD}
ASCENT_INSTALL=${OPT_PATH}/ascent/0bb51d6
mkdir -p ${ASCENT_INSTALL}
echo Ascent env setup: SUCCESS
echo Ascent compile: BEGIN
pushd ${ASCENT_BUILD}
echo "set(BUILD_SHARED_LIBS ON CACHE BOOL \"\")    
set(CMAKE_C_COMPILER \"/sw/summit/gcc/5.4.0/bin/gcc\" CACHE PATH \"\")
set(ENABLE_OPENMP OFF CACHE BOOL \"\")
set(ENABLE_CUDA ON CACHE BOOL \"\")
set(ENABLE_MPI  ON CACHE BOOL \"\")
set(CONDUIT_DIR \"${CONDUIT_INSTALL}\" CACHE PATH \"\")
set(VTKM_DIR \"${VTKM_INSTALL}\" CACHE PATH \"\")
set(HDF5_DIR \"/autofs/nccs-svm1_sw/summit/.swci/1-compute/opt/spack/20180914/linux-rhel7-ppc64le/xl-16.1.1-3/hdf5-1.10.3-lkiyvnhwujxwna67ldnlzslvoqgjavyr\"  CACHE PATH \"\")
set(VTKH_DIR \"${VTKH_INSTALL}\" CACHE PATH \"\")" > ../host-configs/summit.cmake
cmake -C ../host-configs/summit.cmake -DCMAKE_C_COMPILER=/sw/summit/gcc/5.4.0/bin/gcc -DCMAKE_CXX_COMPILER=/sw/summit/gcc/5.4.0/bin/g++ -DCMAKE_BUILD_TYPE=Release -DENABLE_PYTHON=OFF -DCMAKE_INSTALL_PREFIX=${ASCENT_INSTALL} ../src
echo Ascent compile: SUCCESS
echo Ascent install: BEGIN
make install -j 50
popd
echo Ascent install: SUCCESS

echo Amrex env setup: BEGIN
git clone --recursive https://github.com/Alpine-DAV/amrex.git ${OPT_PATH}/amrex/src
pushd ${OPT_PATH}/amrex/src
git checkout 6c95169d36a5dec2406f67830aecb89253593e14
git submodule init
git submodule update
popd
echo Amrex env setup: NOT REQUIRED
echo Amrex compile: NOT REQUIRED
echo Amrex install: NOT REQUIRED

echo Nyx env setup: BEGIN
git clone --recursive https://github.com/Alpine-DAV/nyx.git ${OPT_PATH}/nyx/src
pushd ${OPT_PATH}/nyx/src
git checkout 359ba38c7e458b21dd16be89ff1d3c206be757be
git submodule init
git submodule update
popd
# nyx paths
#Nyx build process doesn't allow me to follow the build dir paradigm
NYX_BUILD=${OPT_PATH}/nyx/src/Exec/LyA
AMREX_HOME=${OPT_PATH}/amrex/src
ASCENT_HOME=${ASCENT_INSTALL}
echo Nyx env setup: SUCCESS
echo Nyx compile: BEGIN
pushd ${NYX_BUILD}
cat GNUmakefile | sed 's/USE_MPI = FALSE/USE_MPI = TRUE/' | sed 's/USE_OMP = FALSE/USE_OMP = TRUE/' >./tmp; cat ./tmp >GNUmakefile; rm ./tmp;
make -j 50 ASCENT_HOME=${ASCENT_HOME} AMREX_HOME=${AMREX_HOME}
echo Nyx compile: SUCCESS
echo Nyx Ascent JSON input dump: BEGIN
echo "[
 {
    \"action\": \"add_pipelines\",
    \"pipelines\":
    {
      \"pipe1\":
      {
          \"f1\":
          {
            \"type\": \"histsampling\",
            \"params\":
            {
              \"field\": \"Density\"
            }
          }
      }
    }
  },

  {
    \"action\": \"add_scenes\",
    \"scenes\":
    { \"s3\":
      {
        \"plots\":
        {
          \"p1\":
          {
            \"type\": \"pseudocolor\",
            \"pipeline\": \"pipe1\",
            \"field\": \"valSampled\"
          }
        },

        \"renders\":
        {
          \"r1\":
            {
              \"type\": \"cinema\",
              \"phi\": \"4\",
              \"theta\": \"4\",
              \"db_name\": \"Nyx_db_sampling\",
              \"fg_color\": [0.0, 0.0, 0.0],
              \"bg_color\": [1.0, 1.0, 1.0],
              \"annotations\": \"false\"
            }
        }
      }
    }
  },

  {
   \"action\": \"execute\"
  },

  {
   \"action\": \"reset\"
  }
]" > ascent_actions.json
echo Nyx Ascent JSON input dump: DONE
popd

### BEGIN ANALYSIS DEPENDENCIES
echo Cinema installation: BEGIN
module load python/3.6.6-anaconda3-5.3.0
pushd submodules/cinema_lib
pip install --user .
popd
echo Cinema installation: SUCCESS

