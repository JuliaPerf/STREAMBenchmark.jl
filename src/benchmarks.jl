"""
Four times the size of the outermost cache (rule of thumb "laid down by Dr. Bandwidth").
"""
default_vector_length() = Int(4 * last(cachesize()) / sizeof(Float64))

_nthreads_string() = avxt() ? "@avxt" : string(nthreads())

function _run_kernels(copy, scale, add, triad;
                      verbose=true,
                      N=default_vector_length(),
                      evals_per_sample=5,
                      write_allocate=true)
    # initialize
    A, B, C, D, s = zeros(N), zeros(N), zeros(N), zeros(N), rand();

    α = write_allocate ? 24 : 16
    β = write_allocate ? 32 : 24

    f = t -> N * α * 1e-6 / t
    g = t -> N * β * 1e-6 / t

    # COPY
    t_copy = @belapsed copy($C, $A) samples=10 evals=evals_per_sample
    bw_copy = f(t_copy)
    verbose && println("╟─ COPY:  ", round(bw_copy, digits=1), " MB/s")

    # SCALE
    t_scale = @belapsed scale($B, $C, $s) samples=10 evals=evals_per_sample
    bw_scale = f(t_scale)
    verbose && println("╟─ SCALE: ", round(bw_scale, digits=1), " MB/s")

    # ADD
    t_add = @belapsed add($C, $A, $B) samples=10 evals=evals_per_sample
    bw_add = g(t_add)
    verbose && println("╟─ ADD:   ", round(bw_add, digits=1), " MB/s")

    # TRIAD
    t_triad = @belapsed triad($A, $B, $C, $s) samples=10 evals=evals_per_sample
    bw_triad = g(t_triad)
    verbose && println("╟─ TRIAD: ", round(bw_triad, digits=1), " MB/s")

    # statistics
    values = [bw_copy, bw_scale, bw_add, bw_triad]
    calc = f->round(f(values), digits=1)

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
    println("╠══╡ ($(_nthreads_string()) threads)")
    nt_multi = _run_kernels(copy_threaded, scale_threaded, add_threaded, triad_threaded; kwargs...)
    println("╟─────────────────────")
    println("║ Median: ", nt_multi.median, " MB/s")
    println("╚═════════════════════")
    println()
    return (single=nt_single, multi=nt_multi)
end


"""
    memory_bandwidth(; verbose=false, multithreading=nthreads() > 1, kwargs...)

Measure the memory bandwidth in megabytes per second (MB/s). Returns a named tuple
indicating the median, minimum, and maximum of the measurements in this order.
"""
function memory_bandwidth(; verbose=false,
                            multithreading=nthreads() > 1,
                            kwargs...)
    c = multithreading ? copy_threaded : copy
    s = multithreading ? scale_threaded : scale
    a = multithreading ? add_threaded : add
    t = multithreading ? triad_threaded : triad
    if verbose
        multithreading ? println("╔══╡ Multi-threaded:") : println("╔══╡ Single-threaded:")
        println("╠══╡ ($(_nthreads_string()) threads)")
    end
    nt = _run_kernels(c, s, a, t; verbose, kwargs...)
    if verbose
        println("╟─────────────────────")
        println("║ Median: ", nt.median, " MB/s")
        println("╚═════════════════════")
    end
    return nt
end


"""
    vector_length_dependence(; n=4, evals_per_sample=1) -> Dict

Measure the memory bandwidth for multiple vector lengths corresponding to
factors of the size of the outermost cache.
"""
function vector_length_dependence(; n=4, evals_per_sample=1)
    outer_cache_size = CpuId.cachesize()[end]
    Ns = floor.(Int, range(1,4,length=n) .* outer_cache_size)
    membws = Dict{Int, Float64}()
    for (i, N) in pairs(Ns)
        m, _, _ = memory_bandwidth(N=N, evals_per_sample=evals_per_sample)
        membws[N] = m
        println(i,": ", N => m)
    end
    return membws
end