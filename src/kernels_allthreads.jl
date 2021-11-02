avxt() = false

macro threaded(code)
    return esc(:(
        if $(@__MODULE__).avxt()
            @avxt($code)
        else
            @threads($code)
        end
    ))
end

# multithreaded kernels
function copy_allthreads(C, A; kwargs...)
    @assert length(C) == length(A)
    @threaded for i in eachindex(C, A)
        @inbounds C[i] = A[i]
    end
    return nothing
end

function scale_allthreads(B, C, s; kwargs...)
    @assert length(C) == length(B)
    @threaded for i in eachindex(C)
        @inbounds B[i] = s * C[i]
    end
    return nothing
end

function add_allthreads(C, A, B; kwargs...)
    @assert length(C) == length(B) == length(A)
    @threaded for i in eachindex(C)
        @inbounds C[i] = A[i] + B[i]
    end
    return nothing
end

function triad_allthreads(A, B, C, s; kwargs...)
    @assert length(C) == length(B) == length(A)
    @threaded for i in eachindex(C)
        @inbounds A[i] = B[i] + s * C[i]
    end
    return nothing
end