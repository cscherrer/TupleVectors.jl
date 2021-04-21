using StatsBase

export summarize

abstract type Summary end

summarize(nt::NamedTuple) = rmap(summarize, nt)

summarize(tv::TupleVector) = summarize(unwrap(tv))

import Base


###############################################################################
# FullSummary

struct FullSummary{T} <: Summary
    data :: T
end

summarize(x) = FullSummary(x)

Base.show(io, s::FullSummary) = print(io, s.data)

###############################################################################
# RealSummary
export RealSummary
struct RealSummary <: Summary
    μ :: Float64
    σ :: Float64

    function RealSummary(μ,σ)
        μ = isnan(μ) ? 0.0 : μ
        σ = isnan(σ) ? 0.0 : σ
        new(μ,σ)
    end
end

Base.typeinfo_prefix(io::IO, ::AbstractArray{<:Summary}) = ("", false)

function Base.show(io::IO, s::RealSummary)
    io = IOContext(io, :compact => true)
    σ = round(s.σ, sigdigits=2)
    if s.μ == 0 || σ == 0
        μdigits = 2
    else
        μdigits = max(0, ceil(Int, log10(2) * (exponent(s.μ) - exponent(σ))) + 2)
    end
    μ = round(s.μ, sigdigits = μdigits)
    print(io, μ, "±", σ)
end

summarize(x::AbstractVector{<:Real}) = RealSummary(mean_and_std(x)...)

function summarize(x::AbstractArray{<:AbstractArray{T}}) where {T <: Real}
    [RealSummary(μ,σ) for (μ,σ) in zip(mean_and_std(x)...)]
end
