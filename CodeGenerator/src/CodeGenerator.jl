module CodeGenerator
import Base:show

Terminal = Symbol
Nonterminal =Symbol
Token=Union{Terminal,Nonterminal}
Statement = Vector{Token}
Production=Dict{Token,Set{Statement}}


include("grammar.jl")
include("generator.jl")

end # module
