SetID = Int64

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
        for next in get(fa.f[s], :ϵ, StateSet()) 
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
    𝐙 = filter(keys(𝐊)) do s
        any(∈(fa.𝐙), 𝐊[s])
    end
    DeterministicFiniteAutomata(keys(𝐊), fa.𝚺, f, S, 𝐙)
end


function remove_useless!(dfa::DeterministicFiniteAutomata)
    queue = State[dfa.𝐒,]
    𝐊 = StateSet()
    push!(𝐊, dfa.𝐒)
    while !isempty(queue)
        s = popfirst!(queue)
        for α in dfa.𝚺
            !haskey(dfa.f[s], α) && continue
            ns = dfa.f[s][α]
            ns ∈ 𝐊 && continue
            push!(queue, ns)
            push!(𝐊, ns)
        end
    end
    empty!(dfa.𝐊)
    union!(dfa.𝐊, 𝐊)
end


function state2stid(𝐏::Vector{StateSet})
    set_tabel = Dict{State,SetID}()
    for (i, st) in 𝐏
        for s ∈ st
            set_tabel[s] = i
        end
    end
    set_tabel
end



function segmentation!(𝐏::Vector{StateSet}, f::Transition{State}, 𝚺::SymbolTabel)
    set_tabel = state2stid(𝐏)
    i = 1
    while i <= length(𝐏)
        stateset = 𝐏[i]
        length(stateset) == 1 && i += 1 && continue
        cnt = 0
        for α ∈ 𝚺
            new_set = Dict{SetID,StateSet}()
            for state in stateset
                next_state = get(f[state], α, state)
                state_id = set_tabel[next_state]
                !haskey(new_set, state_id) && new_set[state_id] = StateSet()
                push!(new_set[state_id], state)
            end
            if length(new_set) > 1
                for set in values(new_set)
                    splice!(𝐏, i, set)
                    foreach(x -> set_tabel[x] = length(𝐏), set)
                end
                break
            end
            cnt += 1
        end
        cnt == length(𝚺) && i += 1
    end
    𝐏                    
end


function reset!(f::Transition{State}, src::State, dst::State)
    for k in keys(f)
        if k == src
            delete!(f, k)
        else
            for e in keys(f[k])
                v = f[k][e]
                v == src && f[k][e] = dst
            end
        end
    end
    f
end

"DFA化简（最小化）"
function simplify!(dfa::DeterministicFiniteAutomata)
    remove_useless!(dfa)
    # 分割法
    𝐏 = StateSet[setdiff(dfa.𝐊, dfa.𝐙),dfa.𝐙]
    segmentation!(𝐏, dfa.f, dfa.𝚺)
    for set in 𝐏
        state = pop!(set)
        while !isempty(set)
            removed = pop!(set)
            reset!(dfa.f, removed, state)
        end
    end
    dfa
end
    