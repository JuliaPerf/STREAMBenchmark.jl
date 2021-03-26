module STREAMBenchmark

using CpuId, BenchmarkTools
using Statistics
using Base.Threads: nthreads, @threads

include("kernels.jl")
include("benchmarks.jl")

export memory_bandwidth

end
