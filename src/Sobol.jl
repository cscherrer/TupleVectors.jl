using Sobol: SobolSeq

export SobolHypercube
using Sobol

struct SobolHypercube{k} <: Hypercube{k}
    seq :: SobolSeq{k}
    value :: Vector{Float64}
    index :: Ref{Int}  # start at zero

    function SobolHypercube(k::Int)
        seq = SobolSeq(k)
        value = Sobol.next!(seq)
        return new{k}(seq, value, 0)
    end
end

function Sobol.next!(s::SobolHypercube)
    s.index[] = 0
    Sobol.next!(s.seq, s.value)
end


function Base.rand(ω::SobolHypercube{k}) where {k}
    ω.value[ω.index[] += 1]
end

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
