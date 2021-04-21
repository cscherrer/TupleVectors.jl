using TupleVectors
using Documenter

DocMeta.setdocmeta!(TupleVectors, :DocTestSetup, :(using TupleVectors); recursive=true)

makedocs(;
    modules=[TupleVectors],
    authors="Chad Scherrer <chad.scherrer@gmail.com> and contributors",
    repo="https://github.com/cscherrer/TupleVectors.jl/blob/{commit}{path}#{line}",
    sitename="TupleVectors.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://cscherrer.github.io/TupleVectors.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/cscherrer/TupleVectors.jl",
)
