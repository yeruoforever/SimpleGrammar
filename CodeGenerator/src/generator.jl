struct Generator
    πβ::Set{Terminal}
    πβ::Set{Nonterminal}
    π::Production
    π::Dict{Terminal,Function}
end

Generator(π::Grammar) = Generator(π.πβ, π.πβ, π.π, Dict{Terminal,Function}())

function bind(g::Generator, sym::Terminal, f::Function)
    sym β g.πβ && throw(KeyError("$sym not in πβ"))
    g.π[sym] = f
end

function bind(g::Generator, syms::Vector{Terminal}, fs::Vector{Function})
    foreach((s, a) -> bind(g, s, a), zip(syms, fs))      
end


"εΉΏεΊ¦δΌεζη΄’ηζε―θ½ηε₯ε"
function generate_bfs(g::Generator, token::Nonterminal;max_depth::Int64=2)
    queue = Statement[]
    used = Set{Statement}()
    result = Set{Statement}()
	isterminal = β(g.πβ)
    for p in g.π[token]
		if all(isterminal, p)
			push!(result, p)
		else
			push!(queue, p)
			push!(used, p)
		end
	end
    step = 0
    while !isempty(queue)
        num = length(queue)
        @info num
        for _ in 1:num
            p = popfirst!(queue)
            idx = findall(β(g.πβ), p)
            reverse!(idx)
            tmp = Statement[p,]
            for i in idx
                n = length(tmp)
                for j in 1:n 
                    now = popfirst!(tmp)
                    for pp in g.π[p[i]]
                        np=splice(now, i, pp)
                        if all(isterminal, np)
                            push!(result, np)
                        else
                            if np β used && step < max_depth
                                push!(tmp, np)
                                push!(used, np)
                            end
                        end
                    end
                end
            end
            for np in tmp
                push!(queue, np)
            end
        end
        step = step + 1
	end
	true, result |> collect
end

"ζ·±εΊ¦δΌεζη΄’δΊ§ηε―θ½ηε₯ε"
function generate_dfs(g::Generator, token::Nonterminal;max_depth::Int64=10)
    max_depth == 0 && return (false,nothing)
    ps = g.π[token] |> collect
    for i in length(ps):-1:1
        remove_pi = false
        idx = findall(β(g.πβ), ps[i])
        isempty(idx) && continue
        nps = Statement[ps[i],]
        reverse!(idx)
        for j in idx
            (flag, res) = generate_dfs(g, ps[i][j], max_depth=max_depth - 1)
            if !flag
                remove_pi = true
                break
            end
            tmp = Statement[]
            while !isempty(nps)
                now = pop!(nps)
                for r in res
                   np=splice(now, j, r)
                   push!(tmp, np)
                end
            end
            nps = tmp
        end
        if remove_pi
            splice!(ps, i)
        else
            splice!(ps, i, unique!(nps))
        end
    end
    ifelse(isempty(ps), (false, nothing), (true, unique!(ps)))
end

function generate_ternamal(g::Generator, token::Token)
    f = get(g.π, token, () -> string(token))
    f()
end

function generate(g::Generator, token::Token;max_depth::Int64=10,generator::Function=generate_dfs)
    token β g.πβ && return Statement[generate_ternamal(g, token),]
    (flag, states) = generator(g, token;max_depth)
    if !flag 
        @warn "Generate fail."
        return [[string(:Ο΅),]]
    end
    return map(states) do s
        join(map(x -> generate_ternamal(g, x), s), " ")
    end
end