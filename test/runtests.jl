using STREAMBenchmark
using Test, Statistics

Base.Threads.nthreads() > 1 || (@warn "Running test suite with only a single thread!")

# check if we are a GitHub runner
const is_github_runner = haskey(ENV, "GITHUB_ACTIONS")

function with_avxt(f)
    @eval STREAMBenchmark.avxt() = true
    f()
    @eval STREAMBenchmark.avxt() = false
end

VECTOR_LENGTH = 0
if is_github_runner
    VECTOR_LENGTH = 100_000
end
if haskey(ENV, "STREAM_VECTOR_LENGTH")
    VECTOR_LENGTH = parse(Int, ENV["STREAM_VECTOR_LENGTH"])
end
if !iszero(VECTOR_LENGTH)
    @info("Using vector length: ", VECTOR_LENGTH)
end

@testset "STREAMBenchmark.jl" begin
    @testset "Benchmarks" begin
        @test STREAMBenchmark.default_vector_length() >= STREAMBenchmark.last_cachesize() / sizeof(Float64)

        iszero(VECTOR_LENGTH) || (STREAMBenchmark.default_vector_length() = VECTOR_LENGTH)
        @show STREAMBenchmark.default_vector_length()

        # memory_bandwidth
        @test keys(memory_bandwidth()) == (:median, :minimum, :maximum)
        @test 10 < memory_bandwidth().median < 1_000_000
        @test 10 < memory_bandwidth(nthreads=1).median < 1_000_000
        with_avxt() do
            @test 10 < memory_bandwidth().median < 1_000_000
        end
        @test !isnothing(memory_bandwidth(nthreads=max(Threads.nthreads()-1,1)))

        # TODO: add verbose=true test
        membw = memory_bandwidth().median
        membw_nowrtalloc = memory_bandwidth(write_allocate=false).median
        @test (membw > membw_nowrtalloc) || (abs(membw - membw_nowrtalloc) < 0.3 * membw)

        # benchmark
        let nt = benchmark()
            @test keys(nt) == (:single, :multi)
            @test keys(nt.single) == (:median, :minimum, :maximum)
            @test keys(nt.multi) == (:median, :minimum, :maximum)
        end  
        # vector_length_dependence
        let d = STREAMBenchmark.vector_length_dependence(nthreads=1)
            @test typeof(d) == Dict{Int64, Float64}
            @test length(d) == 4
            @test maximum(abs.(diff(collect(values(d))))) / median(values(d)) < 0.2
        end
        let d = STREAMBenchmark.vector_length_dependence(n=2)
            @test length(d) == 2
        end

        # scaling benchmark
        membws = scaling_benchmark()
        @test typeof(membws) == Vector{Float64}
        @test length(membws) == Threads.nthreads()
    end

    @testset "Kernels" begin
        A = [1.0,2.0,3.0,4.0,5.0]
        B = [0.8450044149444245, 0.2991196515689396, 0.5449487174110352, 0.06376462113406589, 0.817610835138292]
        C = [42.0,42.0,42.0,42.0,42.0]
        s = 13

        nthreads = min(2, Threads.nthreads())
        thread_indices = STREAMBenchmark._threadidcs(length(A), nthreads)

        STREAMBenchmark.copy(C, A)
        @test C == A
        STREAMBenchmark.copy_allthreads(C, A)
        @test C == A
        STREAMBenchmark.copy_nthreads(C, A; nthreads, thread_indices)
        @test C == A
        STREAMBenchmark.scale(B,C,s)
        @test B ≈ s .* C
        STREAMBenchmark.scale_allthreads(B,C,s)
        @test B ≈ s .* C
        STREAMBenchmark.scale_nthreads(B,C,s; nthreads, thread_indices)
        @test B ≈ s .* C
        STREAMBenchmark.add(C,A,B)
        @test C ≈ A .+ B
        STREAMBenchmark.add_allthreads(C,A,B)
        @test C ≈ A .+ B
        STREAMBenchmark.add_nthreads(C,A,B; nthreads, thread_indices)
        @test C ≈ A .+ B
        STREAMBenchmark.triad(A,B,C,s)
        @test A ≈ B .+ s .* C
        STREAMBenchmark.triad_allthreads(A,B,C,s)
        @test A ≈ B .+ s .* C
        STREAMBenchmark.triad_nthreads(A,B,C,s; nthreads, thread_indices)
        @test A ≈ B .+ s .* C

        # @avxt threading
        with_avxt() do
           STREAMBenchmark.copy_allthreads(C, A)
           @test C == A
           STREAMBenchmark.scale_allthreads(B,C,s)
           @test B ≈ s .* C
           STREAMBenchmark.add_allthreads(C,A,B)
           @test C ≈ A .+ B
           STREAMBenchmark.triad_allthreads(A,B,C,s)
           @test A ≈ B .+ s .* C
        end
    end

    @testset "Original C STREAM Benchmark" begin
        mktempdir() do tmpdir
            cd(tmpdir) do
                STREAMBenchmark.download_original_STREAM()
                @test isdir("stream")
                isdir("stream") && cd("stream") do
                    @test isfile("stream.c")
                    @test isfile("mysecond.c")
                end

                try
                    STREAMBenchmark.compile_original_STREAM()
                    @test isfile("stream/stream")
                catch e
                    @warn "Compilation of original C STREAM benchmark failed."
                    println(e)
                end
                @test_throws ErrorException STREAMBenchmark.compile_original_STREAM(compiler=:carsten)
            end
        end

        mktempdir() do tmpdir
            cd(tmpdir) do
                @test_logs (:warn,"Couldn't find source code \"stream/stream.c\". Have you run STREAMBenchmark.download_original_STREAM()?") STREAMBenchmark.compile_original_STREAM()
                @test_logs (:warn,"Couldn't find executable \"stream/stream\". Have you run STREAMBenchmark.compile_original_STREAM()?") STREAMBenchmark.execute_original_STREAM()
            end
        end
    end
end
