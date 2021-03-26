# STREAMBenchmark

[![Build Status](https://github.com/crstnbr/STREAMBenchmark.jl/workflows/CI/badge.svg)](https://github.com/crstnbr/STREAMBenchmark.jl/actions)
[![Coverage](https://codecov.io/gh/crstnbr/STREAMBenchmark.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/crstnbr/STREAMBenchmark.jl)

Resources: https://blogs.fau.de/hager/archives/8263, https://www.cs.virginia.edu/stream/

Getting a realistic **estimate** of the achievable **memory bandwidth**.

**Important note:** For now this package only implements a very simple version of the original STREAM benchmark. If time permits, I will improve the benchmark in the future.

## Usage

The function `measure_memory_bandwidth()` performs a STREAM benchmark and estimates the memory bandwidth in megabytes per second (MB/s). It returns a 3-tuple indicating the median, minimum,
  and maximum of the measurements in this order.

```julia
julia> using STREAMBenchmark

julia> measure_memory_bandwidth() # median, minimum, maximum in MB/s
(29275.8, 28330.6, 31153.1)

julia> measure_memory_bandwidth(verbose=true)
COPY:  29841.3 MB/s
SCALE: 31120.8 MB/s
ADD:   28878.3 MB/s
TRIAD: 29361.9 MB/s
(29601.6, 28878.3, 31120.8)
```
