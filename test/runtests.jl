using STREAMBenchmark
using Test
using STREAMBenchmark.CpuId: cachesize

@testset "STREAMBenchmark.jl" begin
	@testset "Benchmarks" begin
		@test STREAMBenchmark.default_vector_length() >= 4*cachesize()[end]
    	@test 1000 < memory_bandwidth(multithreading=false).median < 500_000
   	end

   	@testset "Kernels" begin
   		A = [1.0,2.0,3.0,4.0,5.0]
   		B = [0.8450044149444245, 0.2991196515689396, 0.5449487174110352, 0.06376462113406589, 0.817610835138292]
   		C = [42.0,42.0,42.0,42.0,42.0]
   		s = 13

   		STREAMBenchmark.copy(C, A)
   		@test C == A
		STREAMBenchmark.copy_threaded(C, A)
   		@test C == A

   		STREAMBenchmark.scale(B,C,s)
   		@test B ≈ s .* C
   		STREAMBenchmark.scale_threaded(B,C,s)
   		@test B ≈ s .* C

   		STREAMBenchmark.add(C,A,B)
   		@test C ≈ A .+ B
		STREAMBenchmark.add_threaded(C,A,B)
   		@test C ≈ A .+ B

   		STREAMBenchmark.triad(A,B,C,s)
   		@test A ≈ B .+ s .* C
   		STREAMBenchmark.triad_threaded(A,B,C,s)
   		@test A ≈ B .+ s .* C
   	end
end
