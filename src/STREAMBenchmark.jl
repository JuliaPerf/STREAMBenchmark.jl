module STREAMBenchmark

using BenchmarkTools
using Statistics, Downloads
using Base.Threads: nthreads, @threads
using LoopVectorization

include("kernels_allthreads.jl")
include("kernels_nothreads.jl")
include("kernels_nthreads.jl")
include("benchmarks.jl")
include("original.jl")

export memory_bandwidth, benchmark, scaling_benchmark

end
