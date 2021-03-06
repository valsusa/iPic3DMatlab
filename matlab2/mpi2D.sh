#!/bin/sh

#PBS -l walltime=24:00:00
#!PBS -l walltime=00:05:00
#!PBS -l nodes=4
#!PBS -l nodes=8:ppn=4:ib2
#PBS -l nodes=8:ppn=4

#PBS -N MMS1836.mod14
#PBS -j oe -k eo

echo Start: host `hostname`, date `date`
NPROCS=`wc -l < $PBS_NODEFILE`
echo Number of nodes is $NPROCS
echo PBS id is $PBS_JOBID
echo Assigned nodes: `cat $PBS_NODEFILE`

cd ~/Parsek2D.mod14

mpirun -v -machinefile $PBS_NODEFILE -np $NPROCS ./ParsekEM inputfiles/inputfile.1836-v2

