function read_grammar()
      f = open(joinpath(@__DIR__, "grammar.txt"), "r")
      buffer = read(f, String)
      close(f)
      split(buffer)
end

function isLiteral(word::AbstractString)
      startswith(word, "\"") && endswith(word, "\"")
end

function isTerminal(word::AbstractString)
      startswith(word, "<") && endswith(word, ">")
end

struct Grammar
      𝐕ₜ::Set{Terminal}
      𝐕ₙ::Set{Nonterminal}
      𝐏::Dict{Nonterminal,Set{Statement}}
end

function show(io::IO,x::Grammar)
      print(io,"𝐆( 𝐕ₜ, 𝐕ₙ, 𝐏 ), ")
      print(io,"|𝐕ₜ| = $(length(x.𝐕ₜ)) ,")
      print(io,"|𝐕ₙ| = $(length(x.𝐕ₙ)) ,")
      ps=sum(x.𝐏) do d
            length(d.second)
      end
      println(io,"|𝐏| = $ps")
end

function prettyshow(io::IO,x::Grammar)
      show(io,x)
      print(io,"Terminal\t")
      foreach(x->print(io,x," "),x.𝐕ₜ)
      print(io,"\nNonterminal\t")
      foreach(x->print(io,x," "),x.𝐕ₙ)
      println(io)
      for (k,v) in x.𝐏
            print(io,k)
            for (i,p) in enumerate(v)
                  if i==1 print(io,"\n\t:  ") 
                  else  print(io,"\n\t|  ") end
                  for w in p
                        print(io,string(w)," ")
                  end
            end
            println(io,"\n;")
      end
end

function chooseToken!(𝐕ₜ, 𝐕ₙ, word)
      sym=:ϵ
      if isTerminal(word)
            sym=Symbol(word)
            push!(𝐕ₜ, sym)
      elseif isLiteral(word)
            sym=Symbol(word[2:end - 1])
            push!(𝐕ₜ, sym)
      else  
            sym=Symbol(word)
            push!(𝐕ₙ, sym)
      end
      sym
end


function Grammar(buffer)
      𝐕ₜ = Set{Terminal}()
      𝐕ₙ = Set{Nonterminal}()
      𝐏 = Dict{Nonterminal,Set{Statement}}()
      stack = 0
      current = :ϵ
      production = Symbol[]
      for word in buffer
            if word == "{" 
                  stack+=1
            elseif word == "}"
                  stack-=1
            elseif stack!=0 continue
            elseif current==:ϵ
                  sym=chooseToken!(𝐕ₜ,𝐕ₙ,word)
                  current=Symbol(sym)
                  𝐏[current]=Set{Statement}()
            elseif word ==":" continue
            elseif word =="|"
                  push!(𝐏[current],production)
                  production=Symbol[]
            elseif word ==";"
                  push!(𝐏[current],production)
                  production=Symbol[]
                  current=:ϵ
            else
                  sym=chooseToken!(𝐕ₜ,𝐕ₙ,word)
                  push!(production,sym)
            end
      end
      Grammar(𝐕ₜ,𝐕ₙ,𝐏)
end