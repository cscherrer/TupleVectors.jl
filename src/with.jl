using NestedTuples
export @with

# nt = (x=1,y=3.0)
# with(nt, TypelevelExpr(:(x^2 - y)))

# @with nt begin
#     x^2 - y
# end

#########################################

function NestedTuples.with(m::Module, tv::TupleVector{T,X}, ex::TypelevelExpr{E}) where {T,X,E}
    n = length(tv)
    result = chainvec(NestedTuples.with(m, tv[1], ex), n)
    for j in 2:n
        result[j] = NestedTuples.with(m, tv[j], ex)
    end
    return result
end

# # Example: Box-Muller sampling algorithm
# tv = TupleVector((u=rand(1000), v=rand(1000)))

# @with tv begin
#     r = sqrt(-2 * log(u))
#     (x = r * cospi(2v), y = r * sinpi(2v)) 
# end

function NestedTuples.with(m::Module, n::Int, ex::TypelevelExpr{E}) where {E}
    result = chainvec(NestedTuples.with(m, NamedTuple(), ex), n)
    
    for j in 2:n
        result[j] = NestedTuples.with(m, NamedTuple(), ex)
    end
    return result
end
