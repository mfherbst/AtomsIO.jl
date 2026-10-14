# Setup julia dependencies for docs generation. The local AtomsIO and AtomsIOPython
# are pulled in via the [sources] section of docs/Project.toml (requires Julia 1.11+).
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using AtomsIO
using AtomsIOPython
using Documenter

DocMeta.setdocmeta!(AtomsIO, :DocTestSetup, :(using AtomsIO, AtomsIOPython); recursive=true)

makedocs(;
    modules=[AtomsIO, AtomsIOPython],
    authors="Michael F. Herbst <info@michael-herbst.com> and contributors",
    sitename="AtomsIO",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mfherbst.github.io/AtomsIO.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "saveload.md",
        "file_formats.md",
    ],
    checkdocs=:exports,
)

deploydocs(;
    repo="github.com/mfherbst/AtomsIO.jl",
    devbranch="master",
)
