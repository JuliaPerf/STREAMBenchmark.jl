using STREAMBenchmark
using Test

@testset "STREAMBenchmark.jl" begin
    @test 1000 < memory_bandwidth(multithreading=false).median < 10000
end
