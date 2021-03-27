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
(median = 25723.2, minimum = 25211.5, maximum = 26227.8)

julia> memory_bandwidth(verbose=true)
╔══╡ Multi-threaded:
╟─ COPY:  24772.0 MB/s
╟─ SCALE: 25918.4 MB/s
╟─ ADD:   24352.9 MB/s
╟─ TRIAD: 25025.8 MB/s
╟─────────────────────
║ Median: 24898.9 MB/s
╚═════════════════════
(median = 24898.9, minimum = 24352.9, maximum = 25918.4)
```

### Multithreading

If you start Julia with multiple threads (e.g. `julia -t 4`) and call `memory_bandwidth` the kernel loops will be run in parallel. To disable multithreading you can set the keyword argument `multithreading=false`:

```julia
julia> memory_bandwidth(verbose=true, multithreading=false)
╔══╡ Single-threaded:
╟─ COPY:  24153.9 MB/s
╟─ SCALE: 24478.1 MB/s
╟─ ADD:   25298.8 MB/s
╟─ TRIAD: 24595.5 MB/s
╟─────────────────────
║ Median: 24536.8 MB/s
╚═════════════════════
(median = 24536.8, minimum = 24153.9, maximum = 25298.8)
```

If you want to run both the single- and multi-threaded benchmark at once you can call `benchmark()`:

```julia
julia> benchmark()
╔══╡ Single-threaded:
╟─ COPY:  25533.0 MB/s
╟─ SCALE: 25557.0 MB/s
╟─ ADD:   24526.7 MB/s
╟─ TRIAD: 24900.2 MB/s
╟─────────────────────
║ Median: 25216.6 MB/s
╚═════════════════════

╔══╡ Multi-threaded:
╟─ COPY:  25651.4 MB/s
╟─ SCALE: 25454.5 MB/s
╟─ ADD:   25495.2 MB/s
╟─ TRIAD: 24863.8 MB/s
╟─────────────────────
║ Median: 25474.8 MB/s
╚═════════════════════

(single = (median = 25216.6, minimum = 24526.7, maximum = 25557.0), multi = (median = 25474.8, minimum = 24863.8, maximum = 25651.4))
```

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
