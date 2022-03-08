# TupleVectors

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cscherrer.github.io/TupleVectors.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cscherrer.github.io/TupleVectors.jl/dev) -->
[![Build Status](https://github.com/cscherrer/TupleVectors.jl/workflows/CI/badge.svg)](https://github.com/cscherrer/TupleVectors.jl/actions)
[![Coverage](https://codecov.io/gh/cscherrer/TupleVectors.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cscherrer/TupleVectors.jl)

A `TupleVector` is a vector of named tuples that's stored internally as a named tuple of vectors. For example,
```julia
julia> tv = TupleVector((u = rand(3), z = randn(3)))
3-element TupleVector with schema (u = Float64, z = Float64)
(u = 0.42±0.33, z = 1.1±1.5)

julia> TupleVectors.unwrap(tv)
(u = [0.14975088814532667, 0.7856209553858793, 0.31574449850794095], z = [2.674728297554503, -0.3239546802964563, 1.0536358658855687])
```

The `0.42±0.33` above is a `RealSummary`, and comes from `summarize`. This can be called independently as well:
```julia
julia> summarize(1:100)
50.5±29.0
```

You can get or set values by index or name:
```julia
julia> tv[1] = (u=π-3, z=ℯ)
(u = 0.14159265358979312, z = ℯ)

julia> tv[1]
(u = 0.14159265358979312, z = 2.718281828459045)

julia> tv.z
3-element Vector{Float64}:
  2.718281828459045
 -0.3239546802964563
  1.0536358658855687
```

TupleVectors is based on NestedTuples.jl, so of course they can be nested:
```julia
julia> nested = TupleVector((x = randn(1000), y = (a = 1:1000, b = 1 ./ randn(1000))))
1000-element TupleVector with schema (x = Float64, y = (a = Int64, b = Float64))
(x = -0.03±0.99, y = (a = 500.0±290.0, b = 4.0±120.0))
```

`map` can be awkward with nested structures, so we can use `NestedTuple.rmap`. Note that we need to broadcast over the arrays.

```julia
julia> rmap(x -> log.(x .^ 2) , nested)
1000-element TupleVector with schema (x = Float64, y = (a = Float64, b = Float64))
(x = -1.2±2.1, y = (a = 11.8±2.0, b = 1.3±2.2))
```

For more complex structures, it can be useful to initialize separately. This way TupleVectors can determine appropriate types to use.

```julia
julia> fancy = TupleVector(undef, (x=[1,2,3],y=rand(3,2), z=true), 10)
10-element TupleVector with schema (x = Vector{Int64}, y = Matrix{Float64}, z = Bool)
(x = [1.4e13±4.4e13, 0.0±0.0, 1.4e13±4.4e13], y = [6.21245e-310±0.0 6.21245e-310±0.0; 6.21245e-310±0.0 5.52218e-310±0.0; 6.21245e-310±0.0 5.52218e-310±0.0], z = 0.1±0.32)

julia> fancy.x
2-element ArraysOfArrays.ArrayOfSimilarArrays{Int64, 1, 1, 2, ElasticArrays.ElasticMatrix{Int64, 1, Vector{Int64}}}:
 [11, 2, 139711215933697]
 [17, 4, 29441]

julia> fancy.y
2-element ArraysOfArrays.VectorOfSimilarArrays{Float64, 2, 3, ElasticArrays.ElasticArray{Float64, 3, 2, Vector{Float64}}}:
 [0.0 0.0; 0.0 0.0; 0.0 0.0]
 [0.0 0.0; 0.0 0.0; 0.0 0.0]

julia> fancy.z
2-element ElasticArrays.ElasticVector{Bool, 0, Vector{Bool}}:
 1
 0
```

Setting things up this way makes it so we can still `push!` to the TupleVector:
```julia
julia> push!(fancy, (x = [7,8,9], y = rand(3,2), z = true))
4-element TupleVector with schema (x = Vector{Int64}, y = Matrix{Float64}, z = Bool)
(x = [10.5±4.7, 5.5±3.0, 3.5e13±7.0e13], y = [0.19±0.39 0.048±0.096; 0.064±0.13 0.051±0.1; 0.23±0.46 0.2±0.4], z = 0.5±0.58)
```

It's often important to be able to create a new `Vector` or `TupleVector` from an existing one. For that we have `@with`:
```julia
julia> tv = TupleVector((u=rand(1000), v=rand(1000)))
1000-element TupleVector with schema (u = Float64, v = Float64)
(u = 0.505±0.29, v = 0.502±0.29)

julia> polar = @with tv begin
              r = hypot(u,v)
              θ = atan(v,u)
              (;r,θ)
              end
1000-element TupleVector with schema (r = Float64, θ = Float64)
(r = 0.77±0.29, θ = 0.78±0.41)
```

`@with` can be extended by adding methods to `NestedTuples.with`. For example, here's on with signature
```julia
NestedTuples.with(m::Module, hcube_nt::NamedTuple{N,Tuple{H}}, n :: Int, ex::TypelevelExpr{E}) where {T,X,E, N, H<:Hypercube}
```

```julia
julia> using TupleVectors, Sobol, UnicodePlots

julia> ω = SobolHypercube(2)
SobolHypercube{2}(2-dimensional Sobol sequence on [0,1]^2, [0.5, 0.5], Base.RefValue{Int64}(0))

julia> tv = @with (;ω) 1000 begin
           x = 2π * rand(ω)
           y = sin(x) + rand(ω)
           (; x, y)
       end
1000-element TupleVector with schema (x = Float64, y = Float64)
(x = 3.14±1.8, y = 0.5±0.77)

julia> @with TupleVectors.unwrap(tv) begin
           scatterplot(x,y)
       end
      ┌────────────────────────────────────────┐ 
    2 │⠀⠀⠀⠀⠀⠀⠤⣲⡞⢳⣶⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⣐⣺⣑⡮⡽⢮⠵⣚⢗⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠠⢖⠟⢵⠆⣝⣳⣟⣫⠔⡫⠺⡢⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠰⣪⡙⣮⢛⣍⡳⢵⡾⢕⡩⢜⠚⠫⣳⢂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⡠⣳⣥⡺⢤⡟⡒⢽⣍⢝⡿⣒⡗⡮⢟⣪⢶⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⢣⢧⡫⢶⣪⡽⠉⠁⠀⠀⠈⠡⢪⢭⠮⣑⡖⡊⢅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⠀⠀⠀⠀│ 
      │⠯⢆⢟⣫⠋⠀⠀⠀⠀⠀⠀⠀⠀⠑⣝⡋⡽⠜⡫⡢⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠖⠀⠀⠀⠀│ 
      │⣞⠞⡔⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⢝⠱⡱⢬⣭⣢⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡐⡘⠭⡥⠀⠀⠀⠀│ 
      │⡔⡝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠣⢢⣒⣓⡡⢳⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣜⠝⣛⣊⠀⠀⠀⠀│ 
      │⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢁⡪⠯⢍⠧⢛⡲⣀⡀⠀⠀⢀⣐⢜⡻⣱⣻⠦⡑⠀⠀⠀⠀│ 
      │⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠙⣝⡛⣟⠿⢯⠯⣫⡛⣻⣛⠿⡽⢿⣯⢟⣟⠋⠉⠉⠉⠉│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⡭⡰⣬⣗⣛⢴⠺⠶⡞⣙⣺⣥⢾⡬⠂⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠯⣐⡮⠶⣩⢵⣥⣽⠰⢵⣚⡜⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠩⣝⡭⢟⣢⣚⣲⠭⡫⠉⠀⠀⠀⠀⠀⠀⠀⠀│ 
   -1 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠵⢍⡽⠭⠓⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      └────────────────────────────────────────┘ 
      0                                        7
```
