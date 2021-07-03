struct Generator
    𝐕ₜ::Set{Terminal}
    𝐕ₙ::Set{Nonterminal}
    𝐏::Production
    𝐀::Dict{Terminal,Function}
end

Generator(𝐆::Grammar) = Generator(𝐆.𝐕ₜ, 𝐆.𝐕ₙ, 𝐆.𝐏, Dict{Terminal,Function}())


function bind(g::Generator, syms::Vector{Terminal}, fs::Vector{Function})
    foreach((s, a) -> bind(g, s, a), zip(syms, fs))      
end

function bind(g::Generator, sym::Terminal, f::Function)
    sym ∉ g.𝐕ₜ && throw(KeyError("$sym not in 𝐕ₜ"))
    g.𝐀[sym] = f
end

"广度优先搜索导致指数型爆炸增长，目前可运行的最大深度为2"
function generate_bfs(g::Generator, token::Nonterminal;max_depth::Int64=2)
    queue = Tuple{Statement,Int64}[]
    used = Set{Statement}()
    result = Set{Statement}()
	isterminal = ∈(g.𝐕ₜ)
    for p in g.𝐏[token]
		if all(isterminal, p)
			push!(result, p)
		else
			push!(queue, (p, 0))
			push!(used, p)
		end
	end
    while !isempty(queue)
		p, step = popfirst!(queue)
		step > max_depth && continue
		idx = findall(∈(g.𝐕ₙ), p)
		reverse!(idx)
		tmp = Statement[p]
		for i in idx
			n = length(tmp)
			for j in 1:n 
				now = popfirst!(tmp)
				for pp in g.𝐏[p[i]]
					np = deepcopy(now)
					splice!(np, i, pp)
					if all(isterminal, np)
						push!(result, np)
					else
						np ∉ used  && push!(tmp,np)
					end
				end
			end
		end
		for np in tmp
			push!(queue, (np, step + 1))
		end
	end
	result|>collect
end

"深度优先搜索产生可能的语句"
function generate_dfs(g::Generator,token::Nonterminal;max_depth::Int64=10)
    # todo

end

function generate_ternamal(g::Generator,token::Token)
    f=get(g.𝐀,token,()->string(token))
    f()
end

function generate(g::Generator,token::Token;max_depth::Int64=10)
    token ∈ g.𝐕ₜ && return Statement[generate_ternamal(g,token),]
    states=generate_bfs(g,token;max_depth)
    return map(states) do s
        join(map(x->generate_ternamal(g,x),s)," ")
    end
end