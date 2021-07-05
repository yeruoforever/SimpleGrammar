function splice(a,idx,rep=nothing)
      res=a[1:idx-1]
      !isnothing(rep) && append!(res,rep)
      append!(res,a[idx+1:end])
      res      
end