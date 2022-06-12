#!/usr/bin/env sh
#SBATCH -J STREAMBenchmark
#SBATCH -N 1
#SBATCH -A pc2-mitarbeiter
#SBATCH -p all
#SBATCH -t 30:00
#SBATCH --hint=nomultithread
#=
ml load lang/Julia/1.7.2-linux-x86_64
export JULIA_NUM_THREADS=40
julia --project $(scontrol show job $SLURM_JOBID | awk -F= '/Command=/{print $2}')
exit
# =#

println("Node: ", gethostname(), "\n")

using Pkg
Pkg.instantiate()
Pkg.precompile()
flush(stdout)
flush(stderr)

using STREAMBenchmark
using ThreadPinning
using UnicodePlots

# thread affinity
pinthreads(:compact)
threadinfo(; color = false)
println()
println("Julia threads are running on the following cores:")
println(getcpuids(), "\n")
flush(stdout)

# membw benchmark
println()
benchmark(N = 64_000_000)
flush(stdout)

# membw scaling benchmark
println()
maximums = scaling_benchmark(N = 64_000_000)
flush(stdout)
p = lineplot(1:Threads.nthreads(), maximums, title = "Memory Bandwidth Scaling",
             xlabel = "# threads", ylabel = "MB/s", border = :ascii, canvas = AsciiCanvas)
println(p)
flush(stdout)
