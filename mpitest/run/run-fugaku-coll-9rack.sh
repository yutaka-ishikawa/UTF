#!/bin/bash
#------ pjsub option --------#
#PJM -N "MPICH-COLL-9Rack" # jobname
#PJM -S		# output statistics
#
#PJM --spath "results/coll-9rack/%n.%j.stat"
#PJM -o "results/coll-9rack/%n.%j.out"
#PJM -e "results/coll-9rack/%n.%j.err"
#
#PJM -L "node=3456"
#	PJM -L "node=1152"
#	PJM --mpi "max-proc-per-node=1"
#	PJM --mpi "max-proc-per-node=32"
#PJM --mpi "max-proc-per-node=4"
#PJM -L "elapse=00:30:30"
#PJM -L "rscunit=rscunit_ft01,rscgrp=eap-llio,jobenv=linux2"
#PJM -L proc-core=unlimited
#------- Program execution -------#
MPIOPT="-of results/coll-9rack/%n.%j.out -oferr results/coll-9rack/%n.%j.err"

NP=13824
export MPIR_CVAR_CH4_OFI_CAPABILITY_SETS_DEBUG=1
#for RED_LEN in 2048 4096 8192 16384 32768
#for RED_LEN in 8192 16384 32768 131072
for RED_LEN in 262144 524288
do
    echo; echo;
    echo "checking Reduce"
    time mpich_exec -n $NP $MPIOPT ../bin/colld -l $RED_LEN -s 0x2 -V 1	#
    unset MPIR_CVAR_CH4_OFI_CAPABILITY_SETS_DEBUG
    echo; echo;
    echo "checking Allreduce"
    time mpich_exec -n $NP $MPIOPT ../bin/colld -l $RED_LEN -s 0x4 -V 1	#
done

exit
echo  "checking collective except Alltoall"
mpiexec -n 165888 $MPIOPT ../bin/colld -l 2 -s 0x3f	#
mpiexec -n 165888 $MPIOPT ../bin/colld -l 1 -s 0x3f	# OK 5774.7 MiB
#mpiexec -n 110592 $MPIOPT ../bin/colld -l 1 -s 0x11	# OK
#mpiexec -n 110592 $MPIOPT ../bin/colld -l 1 -s 0x2f	# OK
#mpiexec -n 110592 $MPIOPT ../bin/colld -l 1 -s 0x3	# OK
#mpiexec -n 65536 $MPIOPT ../bin/colld -l 1 -s 0x3	# OK
#mpiexec -n 110592 $MPIOPT ../bin/coll -l 2 -s 0x2f	# 
#mpiexec -n 110592 $MPIOPT ../bin/colld -l 512 -s 0x2f	# ERROR due to lack of memory
#mpiexec -n 131072 $MPIOPT ../bin/colld -l 512 -s 0x2f	# ERROR due to lack of memory
#mpiexec -n 165888 $MPIOPT ../bin/colld -l 512 -s 0x2f	# ERRORdue to lack of memory
#mpiexec -n 55296 $MPIOPT ../bin/coll -l 512 -s 0x2f	#  3 min 00 sec
#mpiexec -n 36864 $MPIOPT ../bin/coll -l 512 -s 0x2f	#  2 min 13 sec
#mpiexec -n 1152 $MPIOPT ../bin/coll -l 512 -s 0x2f	#  57 sec
#mpiexec -n 3456 $MPIOPT ../bin/coll -l 512 -s 0x2f	#  sec

###########################################################################
###########################################################################
###########################################################################
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
mpiexec -n 110592 $MPIOPT ../bin/coll -l 512 -s 0x2f	#  5 min 57 sec == 72 rack
#mpiexec -n 131072 $MPIOPT ../bin/coll -l 512 -s 0x2f	# ERROR
#mpiexec -n 165888 $MPIOPT ../bin/coll -l 512 -s 0x2f	# ERROR
#mpiexec -n 110592 $MPIOPT ../bin/coll -l 512 -s 0x2f	#  5 min 57 sec == 72 rack
#mpiexec -n 55296 $MPIOPT ../bin/coll -l 512 -s 0x2f	#  3 min 00 sec
#mpiexec -n 36864 $MPIOPT ../bin/coll -l 512 -s 0x2f	#  2 min 13 sec
#mpiexec -n 1152 $MPIOPT ../bin/coll -l 512 -s 0x2f	#  57 sec
#mpiexec -n 3456 $MPIOPT ../bin/coll -l 512 -s 0x2f	#  sec

exit
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
