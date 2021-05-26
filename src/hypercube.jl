using GeneralizedGenerated
using NestedTuples
using Random: AbstractRNG

abstract type Hypercube{k} <: AbstractRNG end


struct RandHypercube{T} <: Hypercube{Inf}
    rng :: T
end

function Base.rand(ω::RandHypercube)
    rand(ω.rng)
end

function Base.rand(ω::Hypercube, ::Type{T}) where {T <: Integer}
    a = typemin(T)
    b = typemax(T)
    p = rand(ω)
    return b*p + a*(1-p)
end

function Base.rand(ω::Hypercube, ::Type{T}) where {T <: AbstractFloat}
    convert(T, rand(ω))
end

function Base.rand(ω::Hypercube, ::Type{T}) where {T <: Complex}
    convert(T, rand(ω) + rand(ω)im)
end

# TODO: Add a test
function NestedTuples.with(m::Module, hcube_nt::NamedTuple{N,Tuple{H}}, tv::TupleVector{T,X}, ex::TypelevelExpr{E}) where {T,X,E, N, H<:Hypercube}
    n = length(tv)
    (ω,) = keys(hcube_nt)
    next!ω_expr = NestedTuples.TypelevelExpr(:($next!($ω)))
    next! = TupleVectors.next!
    NestedTuples.with(m, hcube_nt, next!ω_expr)
    result = @inbounds chainvec(NestedTuples.with(m, hcube_nt, tv[1], ex), n)
    for j in 2:n
        NestedTuples.with(m, hcube_nt, next!ω_expr)
        @inbounds result[j] = NestedTuples.with(m, hcube_nt, tv[j], ex)
    end
    return result
end

# TODO: Add a test
function NestedTuples.with(m::Module, hcube_nt::NamedTuple{N,Tuple{H}}, n :: Int, ex::TypelevelExpr{E}) where {T,X,E, N, H<:Hypercube}
    (ω,) = keys(hcube_nt)
    next!ω_expr = NestedTuples.TypelevelExpr(:($next!($ω)))
    NestedTuples.with(m, hcube_nt, next!ω_expr)
    result = @inbounds chainvec(NestedTuples.with(m, hcube_nt, ex), n)
    for j in 2:n
        NestedTuples.with(m, hcube_nt, next!ω_expr)
        @inbounds result[j] = NestedTuples.with(m, hcube_nt, ex)
    end
    return result
end

# function NestedTuples.with(ω::Hypercube, nt::NamedTuple, ex::TypelevelExpr{E}) where {E}
#     next!(ω)
#     NestedTuples.with(nt, ex)
# end


# TODO: Add interface for Hypercube

# using Colors
# using GLMakie

# function makeplot()
#     ω = SobolHypercube(100)
#     x = range(-2,2,length=100)
#     d = For(x) do xj Normal(2*xj, 1/(1 + xj^2)) end
#     y = rand(ω, d)

#     plt = scatter(x,y,markersize=2, color=colorant"rgba(0,0,0,0.1)")
#     for j in 1:100
#         next!(ω)
#         y = rand(ω, d)
#         scatter!(x, y, markersize=2, color=colorant"rgba(0,0,0,0.1)")
#     end
#     plt
# end

# makeplot()
