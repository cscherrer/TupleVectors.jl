import Tables

Tables.isrowtable(::Type{<:TupleVector}) = true

Tables.columnaccess(::Type{<:TupleVectors}) = true
Tables.columns(tv::TupleVector) = unwrap(tv)



Tables.schema(s::TupleVector{T,X}) where {T,X} = Tables.Schema(T)


# Adapted from StructVectors.jl
function try_compatible_columns(rows::R, s::TupleVector) where {R}
    Tables.isrowtable(rows) && Tables.columnaccess(rows) || return nothing
    T = eltype(rows)
    hasfields(T) || return nothing
    NT = StructArrays.staticschema(T)
    StructArrays._schema(NT) == Tables.schema(rows) || return nothing
    return Tables.columntable(rows)
end

# Adapted from StructVectors.jl
function Base.append!(s::TupleVector, rows)
    table = try_compatible_columns(rows, s)
    if table !== nothing
        # Input `rows` is a container of rows _and_ satisfies column
        # table interface.  Thus, we can add the input column-by-column.
        foreachfield(append!, s, table)
        return s
    else
        # Otherwise, fallback to a generic implementation expecting
        # that `rows` is an iterator:
        return foldl(push!, rows; init = s)
    end
end
