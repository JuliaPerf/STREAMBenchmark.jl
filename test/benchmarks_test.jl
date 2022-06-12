using Test
using STREAMBenchmark
using Statistics

function with_avxt(f)
    @eval STREAMBenchmark.avxt() = true
    f()
    @eval STREAMBenchmark.avxt() = false
end

# check if we are a GitHub runner
const is_github_runner = haskey(ENV, "GITHUB_ACTIONS")

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

@test STREAMBenchmark.default_vector_length() >=
      STREAMBenchmark.last_cachesize() / sizeof(Float64)

iszero(VECTOR_LENGTH) || (STREAMBenchmark.default_vector_length() = VECTOR_LENGTH)
@show STREAMBenchmark.default_vector_length()

# memory_bandwidth
@test keys(memory_bandwidth()) == (:median, :minimum, :maximum)
@test 10 < memory_bandwidth().median < 1_000_000
@test 10 < memory_bandwidth(nthreads = 1).median < 1_000_000
with_avxt() do
    @test 10 < memory_bandwidth().median < 1_000_000
end
@test !isnothing(memory_bandwidth(nthreads = max(Threads.nthreads() - 1, 1)))

# TODO: add verbose=true test
membw = memory_bandwidth().median
membw_nowrtalloc = memory_bandwidth(write_allocate = false).median
@test (membw > membw_nowrtalloc) || (abs(membw - membw_nowrtalloc) < 0.3 * membw)

# benchmark
let nt = benchmark()
    @test keys(nt) == (:single, :multi)
    @test keys(nt.single) == (:median, :minimum, :maximum)
    @test keys(nt.multi) == (:median, :minimum, :maximum)
end
# vector_length_dependence
let d = STREAMBenchmark.vector_length_dependence(nthreads = 1)
    @test typeof(d) == Dict{Int64, Float64}
    @test length(d) == 4
    @test maximum(abs.(diff(collect(values(d))))) / median(values(d)) < 0.2
end
let d = STREAMBenchmark.vector_length_dependence(n = 2)
    @test length(d) == 2
end

# scaling benchmark
membws = scaling_benchmark()
@test typeof(membws) == Vector{Float64}
@test length(membws) == Threads.nthreads()
