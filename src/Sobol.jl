using Sobol: SobolSeq

export SobolHypercube
import Sobol

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


function Base.rand(s::SobolHypercube{k}) where {k}
    s.value[s.index[] += 1]
end



using ArraysOfArrays

export sobolrand!, sobolrandn!

function sobolrand!(s, x::VectorOfSimilarVectors)
    sobolrand!(s, x.data)
    x
end

function sobolrand!(s, x::AbstractMatrix)
    for xcol in eachcol(x)
        Sobol.next!(s, xcol)
    end
    x
end


function sobolrandn!(s, x::VectorOfSimilarVectors)
    sobolrandn!(s, x.data)
    x
end


function sobolrandn!(s, x::AbstractMatrix)
    for xcol in eachcol(x)
        Sobol.next!(s, xcol)
        @inbounds for j in eachindex(xcol)
            xcol[j] = norminvcdf(xcol[j])
        end
    end
    x
end

function sobolrand(n,k, extraskip::Int=0)
    s = SobolSeq(k)
    Sobol.skip(s, n) # recommended in the Sobol.jl README
    for _ in 1:extraskip
        Sobol.next!(s)
    end
    x = Matrix{Float64}(undef, k, n)
    for xcol in eachcol(x)
        Sobol.next!(s, xcol)
    end
    s,nestedview(x)
end

function boxmuller!(x::AbstractVector)
    n = length(x)
    @assert iseven(n)
    @views for j in 1:n÷2
        twoj = 2j
        u = x[twoj-1]
        v = 2 * x[twoj]
        r = sqrt(-2 * log(u))
        x[twoj - 1] = r * cospi(v)
        x[twoj] = r * sinpi(v)
    end
    x
end

using StatsFuns

export sobolrand, sobolrandn

# function sobolrandn(n,k, extraskip::Int=0)
#     k2 = 2 * (k - k ÷ 2)
#     x,s = sobolrand(n, k2, extraskip)
#     boxmuller!.(x)
#     nestedview(view(x.data, 1:k, :)),s
# end

function sobolrandn(n,k, extraskip::Int=0)
    s,x = sobolrand(n, k, extraskip)
    xdata = x.data
    @inbounds for j in eachindex(x.data)
        xdata[j] = norminvcdf(xdata[j])
    end
    s,x
end

# function makeplot()
#     s = SobolHypercube(100)
#     x = range(-2,2,length=100)
#     d = For(x) do xj Normal(2*xj, 1/(1 + xj^2)) end
#     y = rand(s, d)

#     plt = scatter(x,y,markersize=2, color=colorant"rgba(0,0,0,0.1)")
#     for j in 1:100
#         next!(s)
#         y = rand(s, d)
#         scatter!(x, y, markersize=2, color=colorant"rgba(0,0,0,0.1)")
#     end
#     plt
# end
