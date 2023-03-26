# Setup julia dependencies for docs generation if not yet done
import Pkg
Pkg.activate(@__DIR__)
if !isfile(joinpath(@__DIR__, "Manifest.toml"))
    Pkg.develop(Pkg.PackageSpec(path=joinpath(@__DIR__, "..")))
    Pkg.develop(Pkg.PackageSpec(path=joinpath(@__DIR__, "../lib/AtomsIOPython")))
    Pkg.instantiate()
end

using AtomsIO
using AtomsIOPython
using Documenter

DocMeta.setdocmeta!(AtomsIO, :DocTestSetup, :(using AtomsIO, AtomsIOPython); recursive=true)

makedocs(;
    modules=[AtomsIO, AtomsIOPython],
    authors="Michael F. Herbst <info@michael-herbst.com> and contributors",
    repo="https://github.com/mfherbst/AtomsIO.jl/blob/{commit}{path}#{line}",
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
    strict=true
)

deploydocs(;
    repo="github.com/mfherbst/AtomsIO.jl",
    devbranch="master",
)
