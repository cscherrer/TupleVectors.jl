using .MeasureTheory
using ..TupleVectors

function Base.rand(ω::Hypercube, d::ParameterizedMeasure)
    Dists.quantile(distproxy(d), rand(ω))
end

function Base.rand(ω::Hypercube, d::ProductMeasure)
    [rand(ω, dj) for dj in d.data]
end
