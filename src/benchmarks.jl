"""
Four times the size of the outermost cache (rule of thumb "laid down by Dr. Bandwidth").
"""
default_vector_length() = Int(4 * last_cachesize() / sizeof(Float64))

_nthreads_string(nthreads) = avxt() ? "@avxt" : string(nthreads)

function _threadidcs(N, nthreads)
    Nperthread = floor(Int, N / nthreads)
    rest = rem(N, nthreads)
    thread_indices = collect(Iterators.partition(1:N, Nperthread))
    if rest != 0
        # last thread compensates for the nonzero remainder
        thread_indices[end-1] = thread_indices[end-1].start:thread_indices[end].stop
    end
    return thread_indices
end

function _run_kernels(
    copy,
    scale,
    add,
    triad;
    verbose=true,
    N=default_vector_length(),
    evals_per_sample=5,
    write_allocate=true,
    nthreads=Threads.nthreads()
)
    # initialize
    A, B, C, D, s = zeros(N), zeros(N), zeros(N), zeros(N), rand()

    α = write_allocate ? 24 : 16
    β = write_allocate ? 32 : 24

    f = t -> N * α * 1e-6 / t
    g = t -> N * β * 1e-6 / t

    # N / nthreads if necessary
    thread_indices = _threadidcs(N, nthreads)

    # COPY
    t_copy = @belapsed $copy($C, $A; nthreads=$nthreads, thread_indices=$thread_indices) samples = 10 evals = evals_per_sample
    bw_copy = f(t_copy)
    verbose && println("╟─ COPY:  ", round(bw_copy; digits=1), " MB/s")

    # SCALE
    t_scale = @belapsed $scale($B, $C, $s; nthreads=$nthreads, thread_indices=$thread_indices) samples = 10 evals = evals_per_sample
    bw_scale = f(t_scale)
    verbose && println("╟─ SCALE: ", round(bw_scale; digits=1), " MB/s")

    # ADD
    t_add = @belapsed $add($C, $A, $B; nthreads=$nthreads, thread_indices=$thread_indices) samples = 10 evals = evals_per_sample
    bw_add = g(t_add)
    verbose && println("╟─ ADD:   ", round(bw_add; digits=1), " MB/s")

    # TRIAD
    t_triad = @belapsed $triad($A, $B, $C, $s; nthreads=$nthreads, thread_indices=$thread_indices) samples = 10 evals = evals_per_sample
    bw_triad = g(t_triad)
    verbose && println("╟─ TRIAD: ", round(bw_triad; digits=1), " MB/s")

    # statistics
    values = [bw_copy, bw_scale, bw_add, bw_triad]
    calc = f -> round(f(values); digits=1)

    return (median=calc(median), minimum=calc(minimum), maximum=calc(maximum))
end

"""
    benchmark(; kwargs...)

Runs a comprehensive STREAM benchmark. Returns the median, minimum, and maximum
of single- and multi-threaded measurements of the memory_bandwidth (in MB/s).
"""
function benchmark(; kwargs...)
    println("╔══╡ Single-threaded:")
    nt_single = _run_kernels(copy, scale, add, triad; kwargs...)
    println("╟─────────────────────")
    println("║ Median: ", nt_single.median, " MB/s")
    println("╚═════════════════════")
    println()
    println("╔══╡ Multi-threaded:")
    println("╠══╡ ($(_nthreads_string(Threads.nthreads())) threads)")
    nt_multi = _run_kernels(
        copy_allthreads, scale_allthreads, add_allthreads, triad_allthreads; kwargs...
    )
    println("╟─────────────────────")
    println("║ Median: ", nt_multi.median, " MB/s")
    println("╚═════════════════════")
    println()
    return (single=nt_single, multi=nt_multi)
end

"""
    scaling_benchmark(; kwargs...)

Runs a comprehensive STREAM benchmark for a varying number of threads (`1:Threads.nthreads()`).
Returns a vector of the measured maximal memory_bandwidths (in MB/s) for each number of threads.
"""
function scaling_benchmark(; verbose=false, kwargs...)
    if avxt()
        @warn("Won't use @avxt as it isn't compatible with specifying a particular number of threads")
    end
    maximums = zeros(Threads.nthreads())
    for nthreads in 1:Threads.nthreads()
        res = _run_kernels(
            copy_nthreads, scale_nthreads, add_nthreads, triad_nthreads; nthreads, verbose, kwargs...
        )
        maximums[nthreads] = res.maximum
        println("# Threads: ", nthreads, "\t", "Max. memory bandwidth: ", res.maximum)
    end
    return maximums
end

"""
    memory_bandwidth(; verbose=false, nthreads=nthreads() > 1, kwargs...)

Measure the memory bandwidth in megabytes per second (MB/s). Returns a named tuple
indicating the median, minimum, and maximum of the measurements in this order.
"""
function memory_bandwidth(; verbose=false, nthreads=Threads.nthreads(), kwargs...)
    maxthreads = Threads.nthreads()
    if nthreads == 1
        c = copy
        s = scale
        a = add
        t = triad
    elseif nthreads == maxthreads
        c = copy_allthreads
        s = scale_allthreads
        a = add_allthreads
        t = triad_allthreads
    else
        if avxt()
            @warn("Won't use @avxt as it isn't compatible with specifying a particular number of threads")
        end
        c = copy_nthreads
        s = scale_nthreads
        a = add_nthreads
        t = triad_nthreads
    end
    
    if verbose
        nthreads > 1 ? println("╔══╡ Multi-threaded:") : println("╔══╡ Single-threaded:")
        println("╠══╡ ($(_nthreads_string(nthreads)) threads)")
    end
    nt = _run_kernels(c, s, a, t; verbose, nthreads, kwargs...)
    if verbose
        println("╟─────────────────────")
        println("║ Median: ", nt.median, " MB/s")
        println("╚═════════════════════")
    end
    return nt
end

function last_cachesize()
    Base.Cartesian.@nexprs 4 i -> begin
        cs = Int(LoopVectorization.VectorizationBase.cache_size(Val(5-i)))
        cs == 0 || return cs
    end
    0
end

"""
    vector_length_dependence(; n=4, evals_per_sample=1) -> Dict

Measure the memory bandwidth for multiple vector lengths corresponding to
factors of the size of the outermost cache.
"""
function vector_length_dependence(; n=4, evals_per_sample=1, kwargs...)
    outer_cache_size = last_cachesize() / sizeof(Float64)
    Ns = floor.(Int, range(1, 4; length=n) .* outer_cache_size)
    membws = Dict{Int,Float64}()
    for (i, N) in pairs(Ns)
        m, _, _ = memory_bandwidth(; N=N, evals_per_sample=evals_per_sample, kwargs...)
        membws[N] = m
        println(i, ": ", N => m)
    end
    return membws
end
