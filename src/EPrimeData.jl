module EPrimeData

using StringEncodings
using OrderedCollections

export EPrimeLogFile,
        data

# Write your package code here.
include("types.jl")
include("utils.jl")
include("data.jl")

end
