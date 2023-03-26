abstract type AbstractParser end
supports_parsing(::AbstractParser, file; save, trajectory) = false
