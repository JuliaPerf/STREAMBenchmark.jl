module STREAMBenchmark

using CpuId, BenchmarkTools
using Statistics

include("kernels.jl")
include("benchmarks.jl")

export measure_memory_bandwidth

end
