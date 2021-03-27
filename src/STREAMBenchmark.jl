module STREAMBenchmark

using CpuId, BenchmarkTools
using Statistics
using Base.Threads: nthreads, @threads
using LoopVectorization

include("kernels.jl")
include("benchmarks.jl")

export memory_bandwidth, benchmark

end
