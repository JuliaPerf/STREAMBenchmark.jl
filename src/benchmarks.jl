"""
Four times the size of the outermost cache (rule of thumb "laid down by Dr. Bandwidth").
"""
default_vector_length() = 4 * last(cachesize())


"""
	memory_bandwidth(; verbose=false, N=default_vector_length(), evals_per_sample=10)

Measure the memory bandwidth in megabytes per second (MB/s). Returns a 3-tuple
indicating the median, minimum, and maximum of the measurements in this order.
"""
function memory_bandwidth(; verbose=false, N=default_vector_length(), evals_per_sample=10, write_allocate=true)
	# initialize
	A, B, C, D, s = zeros(N), zeros(N), zeros(N), zeros(N), rand();

	α = write_allocate ? 24 : 16
	β = write_allocate ? 32 : 24

	# COPY
	t_copy = @belapsed copy($C, $A) samples=10 evals=evals_per_sample
	membw_copy = N * α * 1e-6 / t_copy
	verbose && println("COPY:  ", round(membw_copy, digits=1), " MB/s")

	# SCALE
	t_scale = @belapsed scale($B, $C, $s) samples=10 evals=evals_per_sample
	membw_scale = N * α * 1e-6 / t_scale
	verbose && println("SCALE: ", round(membw_scale, digits=1), " MB/s")

	# ADD
	t_add = @belapsed add($C, $A, $B) samples=10 evals=evals_per_sample
	membw_add = N * β * 1e-6 / t_add
	verbose && println("ADD:   ", round(membw_add, digits=1), " MB/s")

	# TRIAD
	t_triad = @belapsed triad($A, $B, $C, $s) samples=10 evals=evals_per_sample
	membw_triad = N * β * 1e-6 / t_triad
	verbose && println("TRIAD: ", round(membw_triad, digits=1), " MB/s")

	# statistics
	values = [membw_copy, membw_scale, membw_add, membw_triad]
	
	return round.((median(values), minimum(values), maximum(values)), digits=1)
end


"""
	vector_length_dependence(; n=4, evals_per_sample=5) -> Dict

Measure the memory bandwidth for multiple vector lengths corresponding to
factors of the size of the outermost cache.
"""
function vector_length_dependence(; n=4, evals_per_sample=5)
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









