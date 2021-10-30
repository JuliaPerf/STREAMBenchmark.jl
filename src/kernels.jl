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
function copy_threaded(C, A)
    @assert length(C) == length(A)
    @threaded for i in eachindex(C, A)
        @inbounds C[i] = A[i]
    end
    return nothing
end

function scale_threaded(B, C, s)
    @assert length(C) == length(B)
    @threaded for i in eachindex(C)
        @inbounds B[i] = s * C[i]
    end
    return nothing
end

function add_threaded(C, A, B)
    @assert length(C) == length(B) == length(A)
    @threaded for i in eachindex(C)
        @inbounds C[i] = A[i] + B[i]
    end
    return nothing
end

function triad_threaded(A, B, C, s)
    @assert length(C) == length(B) == length(A)
    @threaded for i in eachindex(C)
        @inbounds A[i] = B[i] + s * C[i]
    end
    return nothing
end

# kernels
function copy(C, A)
    @assert length(C) == length(A)
    for i in eachindex(C, A)
        @inbounds C[i] = A[i]
    end
    return nothing
end

function scale(B, C, s)
    @assert length(C) == length(B)
    for i in eachindex(C)
        @inbounds B[i] = s * C[i]
    end
    return nothing
end

function add(C, A, B)
    @assert length(C) == length(B) == length(A)
    for i in eachindex(C)
        @inbounds C[i] = A[i] + B[i]
    end
    return nothing
end

function triad(A, B, C, s)
    @assert length(C) == length(B) == length(A)
    for i in eachindex(C)
        @inbounds A[i] = B[i] + s * C[i]
    end
    return nothing
end
