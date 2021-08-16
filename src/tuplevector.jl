
using NestedTuples: modify, rmap, unwrap, flatten, Leaves, @with, TypelevelExpr
import NestedTuples

export TupleVector
using ElasticArrays, ArraysOfArrays
struct TupleVector{T,X} <: AbstractVector{T}
    data :: X
end

NestedTuples.unwrap(tv::TupleVector) = getfield(tv, :data)

function TupleVector(data::X) where {X <: NamedTuple}
    T = typeof(rmap(first, data))
    return TupleVector{T,X}(data)
end

function TupleVector(a::AbstractVector{T}) where {T}
    a1 = first(a)

    x = TupleVector(undef, a1, length(a))
    x .= a
    return x
end

function TupleVector(::UndefInitializer, x::T, n::Int) where {T<:NamedTuple}

    function initialize(n::Int)
        f(x::T) where {T} = ElasticVector{T}(undef, n)
        f(x::DenseArray{T,N}) where {T,N} = nestedview(ElasticArray{T,N+1}(undef, size(x)..., n), N)
        return f 
    end

    data = rmap(initialize(n), x)

    return TupleVector{T, typeof(data)}(data)
end

# function TupleVector(x::Union{Tuple, NamedTuple})
#     flattened = flatten(x)
#     @assert allequal(size.(flattened)...)

#     T = typeof(modify(arr -> arr[1], x, Leaves()))
#     N = length(axes(flattened[1]))
#     X = typeof(x)
#     return TupleVector{T,X}(x)
# end

# TupleVector{T}(x...) where {T} = leaf_setter(T)(x...)

import Base

NestedTuples.schema(tv::TupleVector{T}) where {T} = schema(T)

Base.propertynames(tv::TupleVector) = propertynames(unwrap(tv))

function Base.showarg(io::IO, tv::TupleVector{T}, toplevel) where T
    io = IOContext(io, :compact => true)
    print(io, "TupleVector")
    toplevel && println(io, " with schema ", schema(T))
end

Base.show(io::IO, ::MIME"text/plain", tv::TupleVector) = show(io, tv)
Base.show(io::IO, ::MIME"text/html", tv::TupleVector) = show(io, tv)

function Base.show(io::IO, tv::TupleVector)
    summary(io, tv)
    print(io, summarize(tv))
end

function Base.show(io::IO, ::MIME"text/plain", v::Vector{TV}) where {TV <: TupleVector}
    io = IOContext(io, :compact => true)
    n = length(v)
    println(io, n,"-element Vector{$TV}")
    foreach(v) do tv println(io, summarize(tv)) end
end

function Base.getindex(x::TupleVector, j)
        
    # TODO: Bounds checking doesn't affect performance, am I doing it right?
    function f(arr)
        # @boundscheck all(j .∈ axes(arr))
        return @inbounds arr[j]
    end

    modify(f, unwrap(x), Leaves())
end

function Base.setindex!(a::TupleVector, x, j::Int) 
    a1 = flatten(unwrap(a))
    x1 = flatten(x)

    setindex!.(a1, x1, j)
    return a
end

function Base.length(tv::TupleVector)
    length(flatten(unwrap(tv))[1])
end

function Base.size(tv::TupleVector)
    size(flatten(unwrap(tv))[1])
end


# TODO: Make this pass @code_warntype
Base.getproperty(tv::TupleVector, k::Symbol) = maybewrap(getproperty(unwrap(tv), k))

maybewrap(t::Tuple) = TupleVector(t)
maybewrap(t::NamedTuple) = TupleVector(t)
maybewrap(t) = t

NestedTuples.flatten(tv::TupleVector) = TupleVector(flatten(unwrap(tv)))

# leaf_setter(tv::TupleVector) = TupleVector ∘ leaf_setter(unwrap(tv))

# function TupleVector{T}(::UndefInitializer) where {T}
#     return EmptyTupleVector{T}()
# end


# function Base.push!(::EmptyTupleVector{T}, nt::NamedTuple) where {T}
#     function f(x::t, path) where {t}
#         ea = ElasticArray{t}(undef, 0)
#         push!(ea, x)
#         return ea
#     end

#     function f(x::DenseArray{t}, path) where {t}
#         ea = ElasticArray{t}(undef, size(x)..., 0)
#         nv = nestedview(ea, 1)
#         push!(nv, x)
#         return nv
#     end

#     data = fold(f, nt)
#     X = typeof(data)
#     TupleVector{T,X}(data)
# end

export rmap

function NestedTuples.rmap(f, tv::TupleVector)
    return TupleVector(rmap(f, unwrap(tv)))
end

function Base.resize!(tv::TupleVector, n::Int)
    rmap(x -> resize!(x, n), unwrap(tv))
end
