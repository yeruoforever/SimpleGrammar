push!(LOAD_PATH,".")
using CodeGenerator


buffer=CodeGenerator.read_grammar()
g=CodeGenerator.grammar(buffer)
println(g)

CodeGenerator.prettyshow(stdout,g)
