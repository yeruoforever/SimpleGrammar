struct Generator
      𝐕ₜ::Set{Terminal}
      𝐕ₙ::Set{Nonterminal}
      𝐏::Dict{Nonterminal,Production}
      𝐀::Dict{Terminal,Function}
end

Generator(𝐆::Grammar)=Generator(𝐆.𝐏,𝐕ₜ,𝐕ₙ,Dict{Terminal,Function}())


function bind(g::Generator,syms::Vector{Terminal},fs::Vector{Function})
      foreach((s,a)->bind(g,s,a) ,zip(syms,fs))      
end

function bind(g::Generator,sym::Terminal,f::Function)
      sym ∉ g.𝐕ₜ && throw(KeyError("$sym not in 𝐕ₜ"))
      g.𝐀[sym]=f
end
