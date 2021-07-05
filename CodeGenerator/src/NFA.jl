"不确定有穷自动机"
struct FiniteAutomata
    𝐊::StateSet             # 状态集
    𝚺::SymbolTabel          # 字母表
    f::Transition{StateSet} # 状态映射
    𝐒::StateSet             # 开始状态集合
    𝐙::StateSet             # 接受状态集合
end

"可达状态集合"
function move(fa::FiniteAutomata, 𝐈::StateSet, α::Symbol)
    states = StateSet()
    for s in 𝐈
        union!(states, fa.f[s][α])
    end
    states
end

"ϵ-closure ϵ-闭包"
function ϵ_colsure(fa::FiniteAutomata, 𝐈::StateSet)
    states = StateSet(𝐈)
    queue = collect(State, 𝐈)
    while !isempty(queue)
        s = popfirst!(queue)
        for next in fa.f[s][:ϵ]
            if next ∉ states
                push!(states, next)
                push!(queue, next)
            end
        end
    end
    states
end

"是否为确定的有穷自动机"
function isDeterministic(fa::FiniteAutomata)
    for (_, t) in fa.f
        for (_, s) in t
            "若可达状态数大于`1`,则该状态机为不确定的"
            length(s) > 1 && return false
        end
    end
    true
end   

"确定的有穷自动机"
struct DeterministicFiniteAutomata
    𝐊::StateSet             # 状态集合
    𝚺::SymbolTabel          # 字母表
    f::Transition{State}    # 状态转移   
    𝐒::State                # 开始状态
    𝐙::StateSet             # 接受状态集合
end

function createSym!(tb::Dict{Symbol,StateSet}, counter::Ref{Int64}, sts::StateSet)
    sym = Symbol("St_$(counter)")
    tb[sym] = sts
    counter += 1
    return sym
end

"子集法产生新的状态集"
function subset(fa::FiniteAutomata)
    counter = 1
    table = Dict{Symbol,StateSet}()
    f = Transition{Symbol}()
    𝐂₀ = ϵ_colsure(fa, fa.𝐊)
    s₀ = createSym!(table, Ref(counter), 𝐂₀)
    𝐂 = Tuple{StateSet,Symbol}[(𝐂₀, s₀),]   
    𝐓 = Set{StateSet}()
        while !isempty(𝐂)
        (T, s) = popfirst!(𝐂)
        push!(𝐓, T)
        for α in fa.𝚺
            𝐔 = ϵ_colsure(fa, move(fa, T, α))
            𝐔 ∈ 𝐓 && continue
            sym = createSym!(table, Ref(counter), 𝐔)
            !haskey(f, s) && f[s] = Dict{Symbol,Symbol}()
            f[s][α] = sym
            push!(𝐂, (𝐔, sym))
        end
    end
    table, f
end


"Transform NFA to DFA"
function determine(fa::FiniteAutomata)
    𝐊, f = subset(fa)
    S = Symbol("St_1")
    𝐙=filter(keys(𝐊)) do s
        any(∈(fa.𝐙),𝐊[s])
    end
    DeterministicFiniteAutomata(keys(𝐊),fa.𝚺,f,S,𝐙)
end


"DFA化简（最小化）"
function simplify(dfa::DeterministicFiniteAutomata)
    # todo 首先去除无用状态
    # 分割法
    
end