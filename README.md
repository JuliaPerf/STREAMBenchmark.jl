# STREAMBenchmark

[![Build Status](https://github.com/JuliaPerf/STREAMBenchmark.jl/workflows/CI/badge.svg)](https://github.com/JuliaPerf/STREAMBenchmark.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaPerf/STREAMBenchmark.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPerf/STREAMBenchmark.jl)

Getting a realistic **estimate** of the achievable (maximal) **memory bandwidth**.

**Note:** This package implements a simple variant of the [original STREAM benchmark](https://www.cs.virginia.edu/stream/). There also is [BandwidthBenchmark.jl](https://github.com/JuliaPerf/BandwidthBenchmark.jl), which is a variant of [TheBandwidthBenchmark](https://github.com/RRZE-HPC/TheBandwidthBenchmark) (an "extended STREAM benchmark").

## Usage

The function `memory_bandwidth()` estimates the memory bandwidth in megabytes per second (MB/s). It returns a named tuple indicating the median, minimum, and maximum of the four measurements.

```julia
julia> using STREAMBenchmark

julia> memory_bandwidth()
(median = 26885.2, minimum = 26475.1, maximum = 27437.5)

julia> memory_bandwidth(verbose=true)
╔══╡ Multi-threaded:
╠══╡ (6 threads)
╟─ COPY:  26659.2 MB/s
╟─ SCALE: 27236.0 MB/s
╟─ ADD:   26017.5 MB/s
╟─ TRIAD: 26719.0 MB/s
╟─────────────────────
║ Median: 26689.1 MB/s
╚═════════════════════
(median = 26689.1, minimum = 26017.5, maximum = 27236.0)
```

Note that we count / assume write-allocates by default (you can use `write_allocate=false` to disregard them).

### Multithreading

If you start Julia with multiple threads (e.g. `julia -t 4`) and call `memory_bandwidth` the kernel loops will be run in parallel. To disable multithreading you can set the keyword argument `multithreading=false`.

If you want to run both the single- and multi-threaded benchmark at once you can call `benchmark()`:

```julia
julia> benchmark()
╔══╡ Single-threaded:
╟─ COPY:  26572.5 MB/s
╟─ SCALE: 26744.5 MB/s
╟─ ADD:   26942.0 MB/s
╟─ TRIAD: 26943.6 MB/s
╟─────────────────────
║ Median: 26843.2 MB/s
╚═════════════════════

╔══╡ Multi-threaded:
╠══╡ (6 threads)
╟─ COPY:  26586.4 MB/s
╟─ SCALE: 28006.7 MB/s
╟─ ADD:   25329.7 MB/s
╟─ TRIAD: 26576.3 MB/s
╟─────────────────────
║ Median: 26581.3 MB/s
╚═════════════════════

(single = (median = 26843.2, minimum = 26572.5, maximum = 26943.6), multi = (median = 26581.3, minimum = 25329.7, maximum = 28006.7))
```

#### LoopVectorization

You can make STREAMBenchmarks.jl use [LoopVectorization](https://github.com/JuliaSIMD/LoopVectorization.jl)'s `@avxt` instead of `@threads` by setting `STREAMBenchmark.avxt() = true`.

### Thread pinning

It is recommended to start julia with `JULIA_EXLUSIVE=1 julia -t4` (for 4 threads), i.e. to set the environmental variable `JULIA_EXCLUSIVE = 1`. This should pin the used threads to the first `1:nthreads()` cores. Alternatively, one may use [ThreadPinning.jl](https://github.com/carstenbauer/ThreadPinning.jl) or [LIKWID.jl](https://github.com/JuliaPerf/LIKWID.jl).

See https://discourse.julialang.org/t/thread-affinitization-pinning-julia-threads-to-cores/58069 for a discussion of other options like `numactl`.

### Vector length

By default a vector length of four times the size of the outermost cache is used (a rule of thumb ["laid down by Dr. Bandwidth"](https://blogs.fau.de/hager/archives/8263)). To measure the memory bandwidth for a few other factorsas well you might want to use `STREAMBenchmark.vector_length_dependence()`:

```julia
julia> STREAMBenchmark.vector_length_dependence()
1: 12582912 => 27101.3
2: 25165824 => 27096.8
3: 37748736 => 26879.4
4: 50331648 => 26889.9
Dict{Int64, Float64} with 4 entries:
  37748736 => 26879.4
  25165824 => 27096.8
  12582912 => 27101.3
  50331648 => 26889.9
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
  Using options: -O3 -DSTREAM_ARRAY_SIZE=33554432
- Done.

julia> STREAMBenchmark.execute_original_STREAM()
-------------------------------------------------------------
STREAM version $Revision: 5.10 $
-------------------------------------------------------------
This system uses 8 bytes per array element.
-------------------------------------------------------------
Array size = 33554432 (elements), Offset = 0 (elements)
Memory per array = 256.0 MiB (= 0.2 GiB).
Total memory required = 768.0 MiB (= 0.8 GiB).
Each kernel will be executed 10 times.
 The *best* time for each kernel (excluding the first iteration)
 will be used to compute the reported bandwidth.
-------------------------------------------------------------
Your clock granularity/precision appears to be 1 microseconds.
Each test below will take on the order of 31889 microseconds.
   (= 31889 clock ticks)
Increase the size of the arrays if this shows that
you are not getting at least 20 clock ticks per test.
-------------------------------------------------------------
WARNING -- The above is only a rough guideline.
For best results, please be sure you know the
precision of your system timer.
-------------------------------------------------------------
Function    Best Rate MB/s  Avg time     Min time     Max time
Copy:           10745.4     0.049993     0.049963     0.050080
Scale:          10774.3     0.049869     0.049829     0.049904
Add:            11538.8     0.069876     0.069791     0.070274
Triad:          11429.4     0.070508     0.070459     0.070640
-------------------------------------------------------------
Solution Validates: avg error less than 1.000000e-13 on all three arrays
-------------------------------------------------------------

julia> benchmark(write_allocate=false) # the original benchmark doesn't count / assumes the absence of write-allocates
╔══╡ Single-threaded:
╟─ COPY:  10699.4 MB/s
╟─ SCALE: 10542.2 MB/s
╟─ ADD:   11088.3 MB/s
╟─ TRIAD: 11099.2 MB/s
╟─────────────────────
║ Median: 10893.9 MB/s
╚═════════════════════

╔══╡ Multi-threaded:
╟─ COPY:  10625.1 MB/s
╟─ SCALE: 10226.7 MB/s
╟─ ADD:   11052.4 MB/s
╟─ TRIAD: 10902.9 MB/s
╟─────────────────────
║ Median: 10764.0 MB/s
╚═════════════════════

(single = (median = 10893.9, minimum = 10542.2, maximum = 11099.2), multi = (median = 10764.0, minimum = 10226.7, maximum = 11052.4))
```

## Resources

* Original STREAM benchmark (C/Fortran): https://www.cs.virginia.edu/stream/
* Blog post about how to optimize and interpret the benchmark: https://blogs.fau.de/hager/archives/8263
