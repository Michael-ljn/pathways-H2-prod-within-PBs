using lce

initProject("Characterisation");
𝐐=Characterisation!().Matrix

using JLD2

@save "main/modules/Qmatrix.jld2" 𝐐