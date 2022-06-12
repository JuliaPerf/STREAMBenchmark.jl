using Test
using STREAMBenchmark

function with_avxt(f)
    @eval STREAMBenchmark.avxt() = true
    f()
    @eval STREAMBenchmark.avxt() = false
end

A = [1.0, 2.0, 3.0, 4.0, 5.0]
B = [
    0.8450044149444245,
    0.2991196515689396,
    0.5449487174110352,
    0.06376462113406589,
    0.817610835138292,
]
C = [42.0, 42.0, 42.0, 42.0, 42.0]
s = 13

nthreads = min(2, Threads.nthreads())
thread_indices = STREAMBenchmark._threadidcs(length(A), nthreads)

STREAMBenchmark.copy(C, A)
@test C == A
STREAMBenchmark.copy_allthreads(C, A)
@test C == A
STREAMBenchmark.copy_nthreads(C, A; nthreads, thread_indices)
@test C == A
STREAMBenchmark.scale(B, C, s)
@test B ≈ s .* C
STREAMBenchmark.scale_allthreads(B, C, s)
@test B ≈ s .* C
STREAMBenchmark.scale_nthreads(B, C, s; nthreads, thread_indices)
@test B ≈ s .* C
STREAMBenchmark.add(C, A, B)
@test C ≈ A .+ B
STREAMBenchmark.add_allthreads(C, A, B)
@test C ≈ A .+ B
STREAMBenchmark.add_nthreads(C, A, B; nthreads, thread_indices)
@test C ≈ A .+ B
STREAMBenchmark.triad(A, B, C, s)
@test A ≈ B .+ s .* C
STREAMBenchmark.triad_allthreads(A, B, C, s)
@test A ≈ B .+ s .* C
STREAMBenchmark.triad_nthreads(A, B, C, s; nthreads, thread_indices)
@test A ≈ B .+ s .* C

# @avxt threading
with_avxt() do
    STREAMBenchmark.copy_allthreads(C, A)
    @test C == A
    STREAMBenchmark.scale_allthreads(B, C, s)
    @test B ≈ s .* C
    STREAMBenchmark.add_allthreads(C, A, B)
    @test C ≈ A .+ B
    STREAMBenchmark.triad_allthreads(A, B, C, s)
    @test A ≈ B .+ s .* C
end
