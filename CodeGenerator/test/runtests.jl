push!(LOAD_PATH,".")
using CodeGenerator


buffer=CodeGenerator.read_grammar()
g=CodeGenerator.Grammar(buffer)
println(g)

CodeGenerator.prettyshow(stdout,g)

G=CodeGenerator.Generator(g)

CodeGenerator.bind(G,Symbol("<Number>"),()->rand(1:9))

res=CodeGenerator.generate(G,Symbol("Expr");max_depth=6)

for each in res
      println(each)
end

res=CodeGenerator.generate(G,Symbol("Expr");max_depth=2,generator=CodeGenerator.generate_bfs)

for each in res
      println(each)
end