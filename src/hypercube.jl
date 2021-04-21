abstract type Hypercube{k} end


struct RandHypercube{T} <: Hypercube{Inf}
    rng :: T
end

function Base.rand(ω::RandHypercube)
    rand(ω.rng)
end


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
