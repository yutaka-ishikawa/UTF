#!/bin/bash
#------ pjsub option --------#
#PJM -N "MPICH-PINGPONG" # jobname
#PJM -S		# output statistics
#PJM --spath "results/%n.%j.stat"
#PJM -o "results/%n.%j.out"
#PJM -e "results/%n.%j.err"
#
#PJM -L "node=2"
#PJM --mpi "max-proc-per-node=1"
#PJM -L "elapse=00:04:10"
#PJM -L "rscunit=rscunit_ft01,rscgrp=eap-llio,jobenv=linux2"
#PJM -L proc-core=unlimited
#------- Program execution -------#
SAVED_LD_LIBRARY_PATH=$LD_LIBRARY_PATH

MPIOPT="-of results/%n.%j.out -oferr results/%n.%j.err"
#MAX_LEN=134217728	# 128 MB
#MIN_LEN=1024
MIN_LEN=1
MAX_LEN=134217728 # 128 MB
ITER=1000
VRYFY=2

export MPICH_TOFU_SHOW_PARAMS=1
echo "checking pingpong"
mpich_exec -n 2 $MPIOPT ../bin/pingpong -L $MAX_LEN -l $MIN_LEN -i $ITER -V $VRYFY

export LD_LIBRARY_PATH=$SAVED_LD_LIBRARY_PATH
echo; echo
echo "FJMPI"
mpiexec -n 2 $MPIOPT ../bin/pingpong-f -L $MAX_LEN -l $MIN_LEN -i $ITER -V $VRYFY
exit


echo "checking pingpong"
time mpich_exec -n 2 $MPIOPT ../bin/pingpong -L $MAX_LEN -l $MIN_LEN -i $ITER -V $VRYFY
echo; echo
echo "FJMPI"
time mpiexec -n 2 $MPIOPT ../bin/pingpong-f -L $MAX_LEN -l $MIN_LEN -i $ITER -V $VRYFY

exit
