"""
Rule of thumb "laid down by Dr. Bandwidth" for choosing the default vector length.
"""
default_vector_length() = 2 * Int(4 * last(cachesize()) / (6*8))


"""

	measure_memory_bandwidth(; verbose=false, reducer=median, N=default_vector_length())

Measures / estimates the memory bandwidth in megabytes per second (MB/s). Returns a 3-tuple
indicating the median, minimum, and maximum of the measurements in this order.
"""
function measure_memory_bandwidth(; verbose=false, reducer=median, N=default_vector_length(), evals_per_sample=10)
	# initialize
	A, B, C, D, s = zeros(N), zeros(N), zeros(N), zeros(N), rand();

	# COPY
	t_copy = @belapsed copy($C, $A) samples=10 evals=evals_per_sample
	membw_copy = N*24*1e-6/t_copy
	verbose && println("COPY:  ", round(membw_copy, digits=1), " MB/s")

	# SCALE
	t_scale = @belapsed scale($B, $C, $s) samples=10 evals=evals_per_sample
	membw_scale = N*24*1e-6/t_scale
	verbose && println("SCALE: ", round(membw_scale, digits=1), " MB/s")

	# ADD
	t_add = @belapsed add($C, $A, $B) samples=10 evals=evals_per_sample
	membw_add = N*32*1e-6/t_add
	verbose && println("ADD:   ", round(membw_add, digits=1), " MB/s")

	# TRIAD
	t_triad = @belapsed triad($A, $B, $C, $s) samples=10 evals=evals_per_sample
	membw_triad = N*32*1e-6/t_triad
	verbose && println("TRIAD: ", round(membw_triad, digits=1), " MB/s")

	# statistics
	values = [membw_copy, membw_scale, membw_add, membw_triad]
	
	return round.((reducer(values), minimum(values), maximum(values)), digits=1)
end