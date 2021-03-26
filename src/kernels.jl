multithreading() = nthreads() > 1 # defaults to true if threads are available

macro maybethreads(code)
  esc(:(if $(@__MODULE__).multithreading()
    @threads($code)
   else
    $code
   end))
end

# kernels
function copy(C,A)
    @assert length(C) == length(A)
    @inbounds @maybethreads for i in eachindex(C,A)
        C[i] = A[i]
    end
    nothing
end

function scale(B,C,s)
    @assert length(C) == length(B)
    @inbounds @maybethreads for i in eachindex(C)
        B[i] = s * C[i]
    end
    nothing
end

function add(C,A,B)
    @assert length(C) == length(B) == length(A)
    @inbounds @maybethreads for i in eachindex(C)
        C[i] = A[i] + B[i]
    end
    nothing
end

function triad(A,B,C,s)
    @assert length(C) == length(B) == length(A)
    @inbounds @maybethreads for i in eachindex(C)
        A[i] = B[i] + s*C[i]
    end
    nothing
end