using Test
using STREAMBenchmark

mktempdir() do tmpdir
    cd(tmpdir) do
        STREAMBenchmark.download_original_STREAM()
        @test isdir("stream")
        isdir("stream") && cd("stream") do
            @test isfile("stream.c")
            @test isfile("mysecond.c")
        end

        try
            STREAMBenchmark.compile_original_STREAM()
            @test isfile("stream/stream")
        catch e
            @warn "Compilation of original C STREAM benchmark failed."
            println(e)
        end
        @test_throws ErrorException STREAMBenchmark.compile_original_STREAM(compiler = :carsten)
    end
end

mktempdir() do tmpdir
    cd(tmpdir) do
        @test_logs (:warn,
                    "Couldn't find source code \"stream/stream.c\". Have you run STREAMBenchmark.download_original_STREAM()?") STREAMBenchmark.compile_original_STREAM()
        @test_logs (:warn,
                    "Couldn't find executable \"stream/stream\". Have you run STREAMBenchmark.compile_original_STREAM()?") STREAMBenchmark.execute_original_STREAM()
    end
end
