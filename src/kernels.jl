multithreading() = nthreads() > 1 # defaults to true if threads are available

avxt() = false

macro maybethreads(code)
    esc(:(if $(@__MODULE__).multithreading()
        if $(@__MODULE__).avxt()
            @avxt($code)
        else
            @threads($code)
        end
    else
        $code
    end))
end

# kernels
function copy(C,A)
    @assert length(C) == length(A)
    @maybethreads for i in eachindex(C,A)
        @inbounds C[i] = A[i]
    end
    nothing
end

function scale(B,C,s)
    @assert length(C) == length(B)
    @maybethreads for i in eachindex(C)
        @inbounds B[i] = s * C[i]
    end
    nothing
end

function add(C,A,B)
    @assert length(C) == length(B) == length(A)
    @maybethreads for i in eachindex(C)
        @inbounds C[i] = A[i] + B[i]
    end
    nothing
end

function triad(A,B,C,s)
    @assert length(C) == length(B) == length(A)
    @maybethreads for i in eachindex(C)
        @inbounds A[i] = B[i] + s*C[i]
    end
    nothing
end
