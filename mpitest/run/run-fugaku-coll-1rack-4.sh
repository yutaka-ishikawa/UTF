#!/bin/bash
#------ pjsub option --------#
#PJM -N "MPICH-COLL-1rack" # jobname
#PJM -S		# output statistics
#
#PJM --spath "results/coll-1rack/%n.%j.stat"
#PJM -o "results/coll-1rack/%n.%j.out"
#PJM -e "results/coll-1rack/%n.%j.err"
#
#PJM -L "node=384"
#	PJM -L "node=128"
#	PJM --mpi "max-proc-per-node=1"
#PJM --mpi "max-proc-per-node=4"
#	PJM --mpi "max-proc-per-node=8"
#	PJM --mpi "max-proc-per-node=16"
#	PJM --mpi "max-proc-per-node=32"
#	PJM --mpi "max-proc-per-node=48"
#PJM -L "elapse=00:10:30"
#PJM -L "rscunit=rscunit_ft01,rscgrp=eap-llio,jobenv=linux2"
#	PJM -L "rscunit=rscunit_ft01,rscgrp=eap-small,jobenv=linux2"
#PJM -L proc-core=unlimited
#------- Program execution -------#

. ./mpich.env
MPIOPT="-of results/coll-1rack/%n.%j.out -oferr results/coll-1rack/%n.%j.err"

#
#   coll -s  0x1: Barrier, 0x2: Reduce, 0x4: Allreduce, 0x8: Gather, 0x10: Alltoall, 0x20: Scatter
#

##export UTF_DEBUG=0x4000	# statistics

mpiexec -n 1536 $MPIOPT ../bin/coll -l 1024 -s 0x2f	# See MPICH-COLL-1rack.3138355.out
exit

##############################################################################################
##############################################################################################
##############################################################################################
export LD_LIBRARY_PATH=${HOME}/mpich-tofu/lib:$LD_LIBRARY_PATH

export MPIR_CVAR_OFI_USE_PROVIDER=tofu
export MPICH_CH4_OFI_ENABLE_SCALABLE_ENDPOINTS=1
export MPIR_CVAR_ALLTOALL_SHORT_MSG_SIZE=2147483647 # 32768 in default (integer value)
export MPIR_CVAR_CH4_OFI_ENABLE_ATOMICS=-1
export MPIR_CVAR_CH4_OFI_ENABLE_MR_VIRT_ADDRESS=1
export MPIR_CVAR_CH4_OFI_ENABLE_RMA=1
export MPIR_CVAR_CH4_OFI_ENABLE_TAGGED=0
export MPIR_CVAR_CH4_OFI_CAPABILITY_SETS_DEBUG=1
export UT_MSGMODE=0
export UTF_TRANSMODE=1  # Aggressive                                                                                      
export TOFU_NAMED_AV=1

echo "TOFU_NAMED_AV = " $TOFU_NAMED_AV
echo "UTF_MSGMODE   = " $UTF_MSGMODE "(0: Eager, 1: Rendezous)"
echo "UTF_TRANSMODE = " $UTF_TRANSMODE "(0: Chained, 1: Aggressive)"
echo "MPIR_CVAR_CH4_OFI_ENABLE_TAGGED = " $MPIR_CVAR_CH4_OFI_ENABLE_T
#
#   coll -s  0x1: Barrier, 0x2: Reduce, 0x4: Allreduce, 0x8: Gather, 0x10: Alltoall, 0x20: Scatter
#
#
echo  "checking collective except Alltoall"
#mpiexec -n 384 $MPIOPT ../bin/coll -l 512 -s 0x2f	# 21 sec
#mpiexec -n 1536 $MPIOPT ../bin/coll -l 512 -s 0x2f	# 53 sec
#mpiexec -n 3072 $MPIOPT ../bin/coll -l 512 -s 0x2f	# 52 sec
#mpiexec -n 6144 $MPIOPT ../bin/coll -l 512 -s 0x2f	# 35 sec
#mpiexec -n 12288 $MPIOPT ../bin/coll -l 512 -s 0x2f	# 52 sec
#mpiexec -n 18432 $MPIOPT ../bin/coll -l 512 -s 0x2f	# 59 sec

export MPIR_CVAR_ALLTOALL_INTRA_ALGORITHM=brucks
echo "MPIR_CVAR_ALLTOALL_INTRA_ALGORITHM" $MPIR_CVAR_ALLTOALL_INTRA_ALGORITHM
mpiexec -n 18432 $MPIOPT ../bin/coll -l 512 -s 0x3f	# 59 sec
#mpiexec -n 18432 $MPIOPT ../bin/coll -l 512 -s 0x10	# 59 sec
exit
#
#
#mpiexec -n 32 $MPIOPT ../bin/coll -l 512 -s 0xff
#mpiexec -n 384 $MPIOPT ../bin/coll -l 512 -s 0xff
#mpiexec -n 128 $MPIOPT ../bin/coll -l 512 -s 0x1
#mpiexec -n 32 $MPIOPT ../bin/coll -l 512 -s 0x1
#OK mpiexec -n 24 $MPIOPT ../bin/coll -l 512 -s 0x1
#OK mpiexec -n 16 $MPIOPT ../bin/coll -l 512 -s 0x1
#OK mpiexec -n 8 $MPIOPT ../bin/coll -l 512 -s 0x1
#mpiexec -n 128 $MPIOPT ../bin/coll -l 512 -s 0x1

exit
mpiexec -n 1536 $MPIOPT ../bin/coll -l 512 -s 0xff
mpiexec -n 3072 $MPIOPT ../bin/coll -l 512 -s 0xff

#mpiexec ../bin/coll -l 5120 -v -s 


#echo
#echo
##ldd ../bin/coll
#	-x FI_LOG_PROV=tofu \
#	-x MPICH_DBG=FILE \
#	-x MPICH_DBG_CLASS=COLL \
#	-x MPICH_DBG_LEVEL=TYPICAL \
#
#	-x PMIX_DEBUG=1 \
#	-x FI_LOG_LEVEL=Debug \
#
