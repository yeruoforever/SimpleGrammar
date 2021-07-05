module CodeGenerator
import Base:show

# "文法"类型定义
Terminal = Symbol
Nonterminal = Symbol
Token = Union{Terminal,Nonterminal}
Statement = Vector{Token}
Production = Dict{Token,Set{Statement}}

# 状态机类型定义
State = Symbol
StateSet = Set{State}
SymbolTabel = Set{Symbol}
Transition{T} = Dict{State,Dict{Symbol,T}}

include("utils.jl")
include("grammar.jl")
include("generator.jl")
include("NFA.jl")

end # module
