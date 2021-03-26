function copy(C,A)
    @assert length(C) == length(A)
    @inbounds for i in eachindex(C,A)
        C[i] = A[i]
    end
    nothing
end

function scale(B,C,s)
    @assert length(C) == length(B)
    @inbounds for i in eachindex(C)
        B[i] = s * C[i]
    end
    nothing
end

function add(C,A,B)
    @assert length(C) == length(B) == length(A)
    @inbounds for i in eachindex(C)
        C[i] = A[i] + B[i]
    end
    nothing
end

function triad(A,B,C,s)
    @assert length(C) == length(B) == length(A)
    @inbounds for i in eachindex(C)
        A[i] = B[i] + s*C[i]
    end
    nothing
end