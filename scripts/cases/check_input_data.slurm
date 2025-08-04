#!/bin/bash

# place this script in the case directory then submit to the batch system with sbatch

#SBATCH --job-name=ready_case		     # Job name
#SBATCH --mail-type=END,FAIL          	     # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=$USER@ufl.edu     	     # Where to send mail	
#SBATCH --ntasks=1                           # Run on a single CPU
#SBATCH --mem=8gb                            # Job memory request
#SBATCH --time=2:00:00              	     # Time limit hrs:min:sec
#SBATCH --output=check_input_data%j.log	     # Standard output and error log

./check_input_data --download
