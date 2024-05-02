# EPrimeData

[![Build Status](https://github.com/lindemann09/EPrimeData.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lindemann09/EPrimeData.jl/actions/workflows/CI.yml?query=branch%3Amain)


handling EPrime log-data (.txt)

```
ed = EPrimeLogFile("MyExperiment-23-1.txt")
ed

using DataFrames
df = DataFrame(data(ed, level=3))
```

