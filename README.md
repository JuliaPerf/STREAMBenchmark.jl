# STREAMBenchmark

[![Build Status](https://github.com/crstnbr/STREAMBenchmark.jl/workflows/CI/badge.svg)](https://github.com/crstnbr/STREAMBenchmark.jl/actions)
[![Coverage](https://codecov.io/gh/crstnbr/STREAMBenchmark.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/crstnbr/STREAMBenchmark.jl)

Getting a realistic **estimate** of the achievable (maximal) **memory bandwidth**.

**Note** This package implements a simple variant of the [original STREAM benchmark](https://www.cs.virginia.edu/stream/).

## Usage

The function `memory_bandwidth()` estimates the memory bandwidth in megabytes per second (MB/s). It returns a named tuple indicating the median, minimum, and maximum of the four measurements.

```julia
julia> using STREAMBenchmark

julia> memory_bandwidth()
COPY:  25267.8 MB/s
SCALE: 25491.2 MB/s
ADD:   25440.6 MB/s
TRIAD: 24401.0 MB/s
(median = 25354.2, minimum = 24401.0, maximum = 25491.2)

julia> memory_bandwidth(verbose=false)
(median = 24526.1, minimum = 23562.6, maximum = 25191.3)
```

### Multithreading

If you start Julia with multiple threads (e.g. `julia -t 4`) the kernel loops will be run in parallel (see `STREAMBenchmark.multithreading()`). To disable multithreading you can redefine `STREAMBenchmark.multithreading() = false`.

### Thread pinning

It is probably a good idea to start julia with `JULIA_EXLUSIVE=1 julia`, i.e. to set the environmental variable `JULIA_EXCLUSIVE = 1`. This should pin the used threads to the first `1:nthreads()` cores.

### Vector length

By default a vector length of four times the size of the outermost cache is used (a rule of thumb ["laid down by Dr. Bandwidth"](https://blogs.fau.de/hager/archives/8263)). To measure the memory bandwidth for a few other factorsas well you might want to use `STREAMBenchmark.vector_length_dependence()`:

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
