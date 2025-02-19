# Troubleshooting
## Types of Failures
### Build Failures
### Runtime Failures

## Common SLURM Job Failure Messages

When running jobs on an HPC cluster using SLURM, users may encounter failure messages indicating why a job did not complete successfully. Below are common SLURM error messages and their typical causes and solutions.

1. NODE_FAIL
- **Message**: `Job <job_id> failed, node failure`
- **Cause**: The compute node running the job encountered a hardware or system failure.
- **Solution**:
  - Check system logs (`/var/log/messages`) or consult the cluster administrators.
  - Resubmit the job.
  - Use `sinfo` to check the node status and avoid requesting faulty nodes.

2. TIMEOUT
- **Message**: `Job <job_id> cancelled at <timestamp> because it expired`
- **Cause**: The job exceeded its allocated wall time (`--time` limit).
- **Solution**:
  - Request more time with `--time=HH:MM:SS`.
  - Optimize the job to complete within the time limit.
  - Use checkpointing to save progress and restart the job if needed.

3. OUT_OF_MEMORY
- **Message**: `Job <job_id> killed due to out-of-memory (OOM) condition`
- **Cause**: The job used more memory than allocated (`--mem` or `--mem-per-cpu`).
- **Solution**:
  - Increase memory allocation using `--mem=XXGB` or `--mem-per-cpu=XXMB`.
  - Profile memory usage using `sstat -j <job_id> --format=MaxRSS`.
  - Optimize the program to use memory more efficiently.

4. FAILED
- **Message**: `Job <job_id> failed with exit code <X>`
- **Cause**: The program crashed due to an error such as segmentation fault or missing dependencies.
- **Solution**:
  - Check the job output file (`slurm-<job_id>.out`) for error messages.
  - Debug using tools like `gdb`, `strace`, or `valgrind`.
  - Ensure all required modules and libraries are loaded before job execution.

5. DEPENDENCY NEVER SATISFIED
- **Message**: `Job <job_id> dependency never satisfied`
- **Cause**: A dependent job (`--dependency=afterok:<job_id>`) failed or was never completed.
- **Solution**:
  - Check the status of the parent job using `sacct -j <job_id>`.
  - Resolve any failures in the dependency chain before resubmitting.
  - Consider removing dependencies if they are not necessary.

## Log Files
```bash
# cd to case directory
cd /case/directory/log/files

# list logs by time modified
ls -t

# inspect the most recently modified log file (most likely where failure is indicated)
tail logfile
```

Another way is to grep for errors recursively through your case files.
```bash
# -i flag to ignore case
# -r flag to search recursively
grep -ir error
```

## The CaseStatus File


## Did My Case Fail, or Time Out?<a name="fail_vs_timeout"></a>
There may be a situation that arises where it is difficult to tell if a case has failed, or just timed out. Here's one way to check if it is a time out issue.

```bash
# cd to your case's run directory
cd /blue/GROUP/USER/earth_model_output/cime_output_root/CASE/run

# save the names of the run time log files to a `bash` variable
LOGS=$(ls | grep .log)

# use the stat command to see when they all were last modified
stat $LOGS | grep Modify
```

If all the times printed to the terminal are within a few seconds to a few minutes of each other, your case likely timed out. You can try rebuilding the case after increasing the `JOB_WALLCLOCK_TIME` variable.

