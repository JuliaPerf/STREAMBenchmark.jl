# -fPIC -O3 -msse3 -xc
# icc -O3 -xCORE-AVX2 -ffreestanding -qopenmp -DSTREAM_ARRAY_SIZE=80000000 -DNTIMES=20 stream.c -o stream.omp.AVX2.80M.20x.icc

function download_original_STREAM()
	println("- Creating folder \"stream\"")
	mkdir("stream")
	println("- Downloading C STREAM benchmark")
	Downloads.download("https://www.cs.virginia.edu/stream/FTP/Code/stream.c", "stream/stream.c")
	Downloads.download("https://www.cs.virginia.edu/stream/FTP/Code/mysecond.c", "stream/mysecond.c")
	println("- Done.")
	return nothing
end

function compile_original_STREAM(; compiler=:clang, multithreading=false)
	if !isfile("stream/stream.c")
		@warn("Couldn't find source code \"stream/stream.c\". Have you run STREAMBenchmark.download_original_STREAM()?")
		return nothing
	end

	println("- Trying to compile \"stream.c\" using $(string(compiler))")
	if compiler == :clang
		options = ["-Ofast", "-march=native", "-DSTREAM_ARRAY_SIZE=$(default_vector_length())"] # "-DNTIMES=30"
	elseif compiler == :gcc-10 || compiler == :gcc
		options = ["-O3", "-DSTREAM_ARRAY_SIZE=$(default_vector_length())"]
	else
		error("Unknown compiler option: $compiler.")
	end
	multithreading && push!(options, "-fopenmp")
	println("  Using options: $(join(options, " "))")
	cd("stream") do
		run(`$compiler $options stream.c -o stream`)
	end
	println("- Done.")
	return nothing
end

function execute_original_STREAM()
	if !isfile("stream/stream")
		@warn("Couldn't find executable \"stream/stream\". Have you run STREAMBenchmark.compile_original_STREAM()?")
	else
		run(`stream/stream`)
	end
	return nothing
end