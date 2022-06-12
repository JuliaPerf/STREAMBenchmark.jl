using SafeTestsets

Base.Threads.nthreads() > 1 || (@warn "Running test suite with only a single thread!")

@time begin
    @time @safetestset "Kernels" begin include("kernels_test.jl") end
    @time @safetestset "Benchmarks" begin include("benchmarks_test.jl") end
    @time @safetestset "Original STREAM" begin include("original_STREAM_test.jl") end
end
