push!(LOAD_PATH,".")
using CodeGenerator


buffer=CodeGenerator.read_grammar()
g=CodeGenerator.Grammar(buffer)
println(g)

CodeGenerator.prettyshow(stdout,g)

G=CodeGenerator.Generator(g)

CodeGenerator.bind(G,Symbol("<Number>"),()->rand(0:255))

res=CodeGenerator.generate(G,Symbol("Expr");max_depth=5)

for each in res
      println(each)
end