
"""
chainvec(x::T, n=1)

Return a vector used to store the type T in a SampleChain. Satisfies the law
chainvec(x,n)[1] == x

If `n>1`, the remaining entries will be `undef`. Note that `x` should correspond
to information stored in a single sample. 
"""
function chainvec end


function chainvec(nt::NamedTuple, n=1)
tv = TupleVector(undef, nt, n)
@inbounds tv[1] = nt
return tv
end

function chainvec(x::T, n=1) where {T<:Real}
ev = ElasticVector{T}(undef, n)
@inbounds ev[1] = x
return ev
end

function chainvec(x::T, n=1) where {T}
if isstructtype(T)
    v = StructArrays.replace_storage(ElasticVector, StructVector{T}(undef, n))
    @inbounds v[1] = x
    return v
end
ev = ElasticVector{T}(undef, n)
@inbounds ev[1] = x
return ev
end

function chainvec(x::DenseArray{T,N}, n=1) where {T,N}
nv = nestedview(ElasticArray{T,N+1}(undef, size(x)..., n), N)
@inbounds nv[1] = x
return nv
end
