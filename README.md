# STREAMBenchmark

[![Build Status](https://github.com/crstnbr/STREAMBenchmark.jl/workflows/CI/badge.svg)](https://github.com/crstnbr/STREAMBenchmark.jl/actions)
[![Coverage](https://codecov.io/gh/crstnbr/STREAMBenchmark.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/crstnbr/STREAMBenchmark.jl)

Getting a realistic **estimate** of the achievable **memory bandwidth**.

**Note** This package implements a simple variant of the [original STREAM benchmark](https://www.cs.virginia.edu/stream/).

## Usage

The function `memory_bandwidth()` estimates the (maximal) memory bandwidth in megabytes per second (MB/s). It returns a 3-tuple indicating the median, minimum, and maximum of individual measurements.

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

### Multithreading

If you start Julia with multiple threads (e.g. `julia -t 4`) the benchmark will be run in parallel (see `STREAMBenchmark.multithreading()`). To disable multithreading you can redefine `STREAMBenchmark.multithreading() = false`.

### Vector length

By default a vector length of four times the size of the outermost cache is used. To measure the memory bandwidth for a few other factorsas well you might want to use `STREAMBenchmark.vector_length_dependence()`:

```julia
julia> STREAMBenchmark.vector_length_dependence();
1: 12582912 => 27972.0
2: 25165824 => 26909.8
3: 37748736 => 25931.3
4: 50331648 => 23921.2
```

## Resources

* https://blogs.fau.de/hager/archives/8263
* https://www.cs.virginia.edu/stream/
