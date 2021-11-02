function copy_nthreads(C, A; nthreads, thread_indices, kwargs...)
    @threads :static for tid in 1:nthreads
        @inbounds for i in thread_indices[tid]
            C[i] = A[i]
        end
    end
    return nothing
end

function scale_nthreads(B, C, s; nthreads, thread_indices, kwargs...)
    @threads :static for tid in 1:nthreads
        @inbounds for i in thread_indices[tid]
            B[i] = s * C[i]
        end
    end
    return nothing
end

function add_nthreads(C, A, B; nthreads, thread_indices, kwargs...)
    @threads :static for tid in 1:nthreads
        @inbounds for i in thread_indices[tid]
            C[i] = A[i] + B[i]
        end
    end
    return nothing
end

function triad_nthreads(A, B, C, s; nthreads, thread_indices, kwargs...)
    @threads :static for tid in 1:nthreads
        @inbounds for i in thread_indices[tid]
            A[i] = B[i] + s * C[i]
        end
    end
    return nothing
end
