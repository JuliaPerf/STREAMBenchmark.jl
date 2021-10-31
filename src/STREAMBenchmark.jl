module STREAMBenchmark

using BenchmarkTools
using Statistics, Downloads
using Base.Threads: nthreads, @threads
using LoopVectorization

include("kernels.jl")
include("benchmarks.jl")
include("original.jl")

export memory_bandwidth, benchmark

end
