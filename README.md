# STREAMBenchmark

[![Build Status](https://github.com/crstnbr/STREAMBenchmark.jl/workflows/CI/badge.svg)](https://github.com/crstnbr/STREAMBenchmark.jl/actions)
[![Coverage](https://codecov.io/gh/crstnbr/STREAMBenchmark.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/crstnbr/STREAMBenchmark.jl)

Getting a realistic **estimate** of the achievable **memory bandwidth**.

**Important note:** For now this package only implements a very simple version of the [original STREAM benchmark](https://www.cs.virginia.edu/stream/). If time permits, I will improve the benchmark in the future.

## Usage

The function `memory_bandwidth()` estimates the memory bandwidth in megabytes per second (MB/s). It returns a 3-tuple indicating the median, minimum, and maximum of the measurements in this order.

```julia
julia> using STREAMBenchmark

julia> memory_bandwidth() # median, minimum, maximum in MB/s
(29275.8, 28330.6, 31153.1)

julia> memory_bandwidth(verbose=true)
COPY:  29841.3 MB/s
SCALE: 31120.8 MB/s
ADD:   28878.3 MB/s
TRIAD: 29361.9 MB/s
(29601.6, 28878.3, 31120.8)
```

## Resources

* https://blogs.fau.de/hager/archives/8263
* https://www.cs.virginia.edu/stream/
