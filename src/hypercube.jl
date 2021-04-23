using GeneralizedGenerated
using NestedTuples

abstract type Hypercube{k} end


struct RandHypercube{T} <: Hypercube{Inf}
    rng :: T
end

function Base.rand(ω::RandHypercube)
    rand(ω.rng)
end



function NestedTuples.with(m::Module, hcube_nt::NamedTuple{N,Tuple{H}}, tv::TupleVector{T,X}, ex::TypelevelExpr{E}) where {T,X,E, N, H<:Hypercube}
    n = length(tv)
    
    (ω,) = keys(hcube_nt)
    NestedTuples.with(m, hcube_nt, :(next!($ω)))
    result = @inbounds chainvec(NestedTuples.with(m, hcube_nt, tv[1], ex), n)
    for j in 2:n
        NestedTuples.with(m, hcube_nt, :(next!($ω)))
        @inbounds result[j] = NestedTuples.with(m, hcube_nt, tv[j], ex)
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
