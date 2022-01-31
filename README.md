# STREAMBenchmark

[![CI@PC2](https://git.uni-paderborn.de/pc2-ci/julia/STREAMBenchmark-jl/badges/master/pipeline.svg?key_text=CI@PC2)](https://git.uni-paderborn.de/pc2-ci/julia/STREAMBenchmark-jl/-/pipelines)
<!-- [![Build Status](https://github.com/JuliaPerf/STREAMBenchmark.jl/workflows/CI/badge.svg)](https://github.com/JuliaPerf/STREAMBenchmark.jl/actions) -->
[![Coverage](https://codecov.io/gh/JuliaPerf/STREAMBenchmark.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPerf/STREAMBenchmark.jl)

*Getting a realistic **estimate** of the achievable (maximal) **memory bandwidth***

**Note:** This package implements a simple variant of the [original STREAM benchmark](https://www.cs.virginia.edu/stream/). There also is [BandwidthBenchmark.jl](https://github.com/JuliaPerf/BandwidthBenchmark.jl), which is a variant of [TheBandwidthBenchmark](https://github.com/RRZE-HPC/TheBandwidthBenchmark) (an "extended STREAM benchmark").

## `memory_bandwidth()`

The function `memory_bandwidth()` estimates the memory bandwidth in megabytes per second (MB/s). It returns a named tuple indicating the median, minimum, and maximum of the four measurements.

**Note:** To obtain a reasonable estimate you should start julia with `N` threads, where `N` should match the number of cores (e.g. of a NUMA domain).

**Linux note:** If possible, you should pin the Julia threads (for example to the cores of a NUMA domain) to decrease the variance of the benchmark. The simplest ways to pin `N` Julia threads to the first `N` cores (compact pinning) are 1) settings `JULIA_EXLUSIVE=1` or 2) using [ThreadPinning.jl's](https://github.com/carstenbauer/ThreadPinning.jl) `pinthreads(:compact)`.

```julia
julia> using ThreadPinning

julia> pinthreads(:compact)

julia> using STREAMBenchmark

julia> memory_bandwidth(verbose=true)
╔══╡ Multi-threaded:
╠══╡ (10 threads)
╟─ COPY:  101153.8 MB/s
╟─ SCALE: 100908.0 MB/s
╟─ ADD:   100516.0 MB/s
╟─ TRIAD: 100549.5 MB/s
╟─────────────────────
║ Median: 100728.8 MB/s
╚═════════════════════
(median = 100728.8, minimum = 100516.0, maximum = 101153.8)
```

### Keyword arguments
* `nthreads` (default `Threads.nthreads()`): Use `nthreads` threads for the benchmark. It must hold `1 ≤ nthreads ≤ Threads.nthreads()`.
* `write_allocate` (default: `true`): assume the use / count write allocates.
* `verbose` (default: `false`): verbose output, including the individual results of the streaming kernels.

## `benchmark()`

If you want to run both the single- and multi-threaded benchmark at once you can call `benchmark()` which produces an output like this:

```julia
julia> benchmark()
╔══╡ Single-threaded:
╟─ COPY:  19088.6 MB/s
╟─ SCALE: 18699.8 MB/s
╟─ ADD:   17518.3 MB/s
╟─ TRIAD: 17501.3 MB/s
╟─────────────────────
║ Median: 18109.0 MB/s
╚═════════════════════

╔══╡ Multi-threaded:
╠══╡ (10 threads)
╟─ COPY:  101497.9 MB/s
╟─ SCALE: 101381.9 MB/s
╟─ ADD:   100281.5 MB/s
╟─ TRIAD: 100828.4 MB/s
╟─────────────────────
║ Median: 101105.2 MB/s
╚═════════════════════

(single = (median = 18109.0, minimum = 17501.3, maximum = 19088.6), multi = (median = 101105.2, minimum = 100281.5, maximum = 101497.9))
```

## Scaling

### Number of threads

To assess the scaling of the maximal memory bandwidth with the number of threads, we provide the function `scaling_benchmark()`

```julia
julia> y = scaling_benchmark()
# Threads: 1	Max. memory bandwidth: 19058.7
# Threads: 2	Max. memory bandwidth: 37511.2
# Threads: 3	Max. memory bandwidth: 55204.6
# Threads: 4	Max. memory bandwidth: 68706.6
# Threads: 5	Max. memory bandwidth: 76869.9
# Threads: 6	Max. memory bandwidth: 83669.9
# Threads: 7	Max. memory bandwidth: 88656.0
# Threads: 8	Max. memory bandwidth: 93701.0
# Threads: 9	Max. memory bandwidth: 97093.6
# Threads: 10	Max. memory bandwidth: 101293.9
10-element Vector{Float64}:
  19058.7
  37511.2
  55204.6
  68706.6
  76869.9
  83669.9
  88656.0
  93701.0
  97093.6
 101293.9
 
julia> using UnicodePlots

julia> lineplot(1:length(y), y, title = "Bandwidth Scaling", xlabel = "# cores", ylabel = "MB/s", border = :ascii, canvas = AsciiCanvas)

                            Bandwidth Scaling
               +----------------------------------------+
        110000 |                                        |
               |                                   __r-*|
               |                            __--"""     |
               |                      __-*""            |
               |                 ._-*"                  |
               |              .r*"                      |
               |           .r"`                         |
   MB/s        |         .*'                            |
               |       ./`                              |
               |      .'                                |
               |    ./                                  |
               |  .r`                                   |
               | ./                                     |
               |*`                                      |
         10000 |                                        |
               +----------------------------------------+
                1                                     10
                                 # cores
 ```

### Vector length

By default a vector length of four times the size of the outermost cache is used (a rule of thumb ["laid down by Dr. Bandwidth"](https://blogs.fau.de/hager/archives/8263)). To measure the memory bandwidth for a few other factorsas well you might want to use `STREAMBenchmark.vector_length_dependence()`:

```julia
julia> STREAMBenchmark.vector_length_dependence()
1: 3604480 => 121692.2
2: 7208960 => 99755.5
3: 10813440 => 98705.5
4: 14417920 => 98660.5
Dict{Int64, Float64} with 4 entries:
  10813440 => 98705.5
  7208960  => 99755.5
  3604480  => 1.21692e5
  14417920 => 98660.5
```

## Comparison with original STREAM benchmark

We can download and compile the [C source code](https://www.cs.virginia.edu/stream/FTP/Code/) of the original STREAM benchmark via STREAMBenchmark.jl:

```julia
julia> using STREAMBenchmark

julia> STREAMBenchmark.download_original_STREAM()
- Creating folder "stream"
- Downloading C STREAM benchmark
- Done.

julia> STREAMBenchmark.compile_original_STREAM(compiler=:gcc, multithreading=false)
- Trying to compile "stream.c" using gcc
  Using options: -O3 -DSTREAM_ARRAY_SIZE=14417920
- Done.

julia> STREAMBenchmark.execute_original_STREAM()
-------------------------------------------------------------
STREAM version $Revision: 5.10 $
-------------------------------------------------------------
This system uses 8 bytes per array element.
-------------------------------------------------------------
Array size = 14417920 (elements), Offset = 0 (elements)
Memory per array = 110.0 MiB (= 0.1 GiB).
Total memory required = 330.0 MiB (= 0.3 GiB).
Each kernel will be executed 10 times.
 The *best* time for each kernel (excluding the first iteration)
 will be used to compute the reported bandwidth.
-------------------------------------------------------------
Your clock granularity/precision appears to be 1 microseconds.
Each test below will take on the order of 11047 microseconds.
   (= 11047 clock ticks)
Increase the size of the arrays if this shows that
you are not getting at least 20 clock ticks per test.
-------------------------------------------------------------
WARNING -- The above is only a rough guideline.
For best results, please be sure you know the
precision of your system timer.
-------------------------------------------------------------
Function    Best Rate MB/s  Avg time     Min time     Max time
Copy:           11039.8     0.020987     0.020896     0.021092
Scale:          12491.1     0.018509     0.018468     0.018537
Add:            13370.0     0.025934     0.025881     0.026183
Triad:          13396.9     0.025903     0.025829     0.026223
-------------------------------------------------------------
Solution Validates: avg error less than 1.000000e-13 on all three arrays
-------------------------------------------------------------

julia> memory_bandwidth(verbose=true, nthreads=1, write_allocate=false) # the original benchmark doesn't count / assumes the absence of write-allocates
╔══╡ Single-threaded:
╠══╡ (1 threads)
╟─ COPY:  12749.1 MB/s
╟─ SCALE: 12468.2 MB/s
╟─ ADD:   13095.3 MB/s
╟─ TRIAD: 13131.2 MB/s
╟─────────────────────
║ Median: 12922.2 MB/s
╚═════════════════════
(median = 12922.2, minimum = 12468.2, maximum = 13131.2)
```

## Further Options and Comments

### LoopVectorization

You can make STREAMBenchmarks.jl use [LoopVectorization](https://github.com/JuliaSIMD/LoopVectorization.jl)'s `@avxt` instead of `@threads` by setting `STREAMBenchmark.avxt() = true`. Note, however, that this only works if `nthreads=1` (single thread is used) or `nthreads=Threads.nthreads()` (all threads are used). This because `@avxt` isn't compatible with our way to let the benchmark only run on a subset of the available Julia threads.

### Thread pinning

It is recommended to either set the environmental variable `JULIA_EXCLUSIVE = 1` or use `pinthreads(:compact)` from [ThreadPinning.jl](https://github.com/carstenbauer/ThreadPinning.jl) to pin the used Julia threads to the first `1:nthreads` cores.

See https://discourse.julialang.org/t/thread-affinitization-pinning-julia-threads-to-cores/58069 for a discussion of other options like `numactl` (with caveats).

## Resources

* Original STREAM benchmark (C/Fortran): https://www.cs.virginia.edu/stream/
* Blog post about how to optimize and interpret the benchmark: https://blogs.fau.de/hager/archives/8263


## Acknowledgements

* CI infrastructure is provided by the [Paderborn Center for Parallel Computing (PC²)](https://pc2.uni-paderborn.de/)
