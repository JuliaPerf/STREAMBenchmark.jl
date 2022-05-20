const ORIGINAL_SOURCES = ["https://www.cs.virginia.edu/stream/FTP/Code/", "https://raw.githubusercontent.com/jeffhammond/STREAM/master/"]

"""
Download the C STREAM benchmark source code from https://www.cs.virginia.edu/stream into a new folder "stream".
"""
function download_original_STREAM(; debug=false)
    println("- Creating folder \"stream\"")
    !isdir("stream") && mkdir("stream")
    println("- Downloading C STREAM benchmark")
    done = false
    for src in ORIGINAL_SOURCES
        if !done
            try
                Downloads.download(
                    joinpath(src, "stream.c"), "stream/stream.c"
                )
                Downloads.download(
                    joinpath(src, "mysecond.c"), "stream/mysecond.c"
                )
                done = true
            catch err
                if debug
                    @warn err
                end
            end
        else
            break
        end
    end
    if done
        println("- Done.")
    else
        println("- Couldn't download original STREAM :(")
    end
    return nothing
end

_default_compiler() = Sys.islinux() ? (:gcc) : (:clang)

"""
    compile_original_STREAM(; compiler=_default_compiler(), multithreading=false)

Compile the source code of the C STREAM benchmark ("stream/stream.c") into a binary "stream/stream".
"""
function compile_original_STREAM(; compiler=_default_compiler(), multithreading=false)
    if !isfile("stream/stream.c")
        @warn(
            "Couldn't find source code \"stream/stream.c\". Have you run STREAMBenchmark.download_original_STREAM()?"
        )
        return nothing
    end

    println("- Trying to compile \"stream.c\" using $(string(compiler))")
    if compiler == :clang
        options = [
            "-Ofast", "-DSTREAM_ARRAY_SIZE=$(default_vector_length())"
        ] # "-DNTIMES=30"
        ((Sys.ARCH === :x86_64) || (Sys.ARCH === :i686)) && push!(options, "-march=native")
    elseif compiler == :(gcc - 10) || compiler == :gcc
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

"""
Execute the binary of the C STREAM benchmark (i.e. "stream/stream").
"""
function execute_original_STREAM()
    if !isfile("stream/stream")
        @warn(
            "Couldn't find executable \"stream/stream\". Have you run STREAMBenchmark.compile_original_STREAM()?"
        )
    else
        run(`stream/stream`)
    end
    return nothing
end
