using STREAMBenchmark
using Test, Statistics
using CpuId: cachesize

Base.Threads.nthreads() > 1 || (@warn Running test suite with only a single thread!)

function with_avxt(f)
   @eval STREAMBenchmark.avxt() = true
   f()
   @eval STREAMBenchmark.avxt() = false
end

@testset "STREAMBenchmark.jl" begin
   @testset "Benchmarks" begin
      @test STREAMBenchmark.default_vector_length() >= 4*cachesize()[end]

      # memory_bandwidth
      @test keys(memory_bandwidth()) == (:median, :minimum, :maximum)
      GC.gc(true)
      @test 1000 < memory_bandwidth().median < 500_000
      GC.gc(true)
      @test 1000 < memory_bandwidth(multithreading=false).median < 500_000
      GC.gc(true)
      with_avxt() do
         @test 1000 < memory_bandwidth().median < 500_000
      end
      GC.gc(true)

      # TODO: add verbose=true test
      @test memory_bandwidth().median > memory_bandwidth(write_allocate=false).median
      GC.gc(true)

      # benchmark
      let nt = benchmark()
         @test keys(nt) == (:single, :multi)
         @test keys(nt.single) == (:median, :minimum, :maximum)
         @test keys(nt.multi) == (:median, :minimum, :maximum)
      end
      GC.gc(true)

      # vector_length_dependence
      let d = STREAMBenchmark.vector_length_dependence()
         @test typeof(d) == Dict{Int64, Float64}
         @test length(d) == 4
         @test maximum(abs.(diff(collect(values(d))))) / median(values(d)) < 0.1
      end
      GC.gc(true)
      let d = STREAMBenchmark.vector_length_dependence(n=2)
         @test length(d) == 2
      end
      GC.gc(true)
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

      # @avxt threading
      with_avxt() do
         STREAMBenchmark.copy_threaded(C, A)
         @test C == A
         STREAMBenchmark.scale_threaded(B,C,s)
         @test B ≈ s .* C
         STREAMBenchmark.add_threaded(C,A,B)
         @test C ≈ A .+ B
         STREAMBenchmark.triad_threaded(A,B,C,s)
         @test A ≈ B .+ s .* C
      end
   end
end
