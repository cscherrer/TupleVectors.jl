using .Sobol: SobolSeq
import .Sobol
using ..TupleVectors

export SobolHypercube

struct SobolHypercube{k} <: Hypercube{k}
    seq :: SobolSeq{k}
    value :: Vector{Float64}
    iter :: Iterators.Stateful{Vector{Float64}, Union{Nothing, Tuple{Float64, Int64}}}

    function SobolHypercube(k::Int)
        seq = SobolSeq(k)
        value = Sobol.next!(seq)
        return new{k}(seq, value, Iterators.Stateful(value))
    end
end

export next!

function next!(ω::SobolHypercube)
    Sobol.next!(ω.seq, ω.value)
    ω.iter.nextvalstate = iterate(ω.value)
    ω.iter.taken = 0
    return ω
end


Base.rand(ω::SobolHypercube) = popfirst!(ω.iter)
    

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
