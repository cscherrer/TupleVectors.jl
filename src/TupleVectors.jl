module TupleVectors

using Requires: @require

import Tables
import TypedTables

include("tuplevector.jl")
include("summarize.jl")
include("chainvec.jl")
include("with.jl")
include("hypercube.jl")


function __init__()
    @require GoldenSequences = "e13314f6-e9b3-11e9-0763-f13dff015e8a" begin
        include("optional/GoldenSequences.jl")
    end

    @require MonteCarloMeasurements = "0987c9cc-fe09-11e8-30f0-b96dd679fdca" begin
        include("optional/MonteCarloMeasurements.jl")
    end

    @require Sobol = "ed01d8cd-4d21-5b2a-85b4-cc3bdc58bad4" begin
        include("optional/Sobol.jl")
    end
    
    @require Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f" begin
        include("optional/Distributions.jl")
    end

    @require MeasureTheory = "eadaa1a4-d27c-401d-8699-e962e1bbc33b" begin
        include("optional/MeasureTheory.jl")
    end

end

end
