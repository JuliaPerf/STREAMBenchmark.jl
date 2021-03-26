module STREAMBenchmark

using CpuId, BenchmarkTools
using Statistics

include("kernels.jl")
include("benchmarks.jl")

export memory_bandwidth

end
