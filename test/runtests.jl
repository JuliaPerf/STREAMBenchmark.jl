using TestItemRunner

Base.Threads.nthreads() > 1 || (@warn "Running test suite with only a single thread!")

@run_package_tests

@testitem "Kernels" begin include("kernels_test.jl") end
@testitem "Benchmarks" begin include("benchmarks_test.jl") end
@testitem "Original STREAM" begin include("original_STREAM_test.jl") end
