# kernels
function copy(C, A; kwargs...)
    for i in eachindex(C, A)
        @inbounds C[i] = A[i]
    end
    return nothing
end

function scale(B, C, s; kwargs...)
    for i in eachindex(C)
        @inbounds B[i] = s * C[i]
    end
    return nothing
end

function add(C, A, B; kwargs...)
    for i in eachindex(C)
        @inbounds C[i] = A[i] + B[i]
    end
    return nothing
end

function triad(A, B, C, s; kwargs...)
    for i in eachindex(C)
        @inbounds A[i] = B[i] + s * C[i]
    end
    return nothing
end