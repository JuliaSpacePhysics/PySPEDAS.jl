# PySPEDAS.jl

[![Build Status](https://github.com/Beforerr/PySPEDAS.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Beforerr/PySPEDAS.jl/actions/workflows/CI.yml?query=branch%3Amain)


A simple Julia wrapper around [PySPEDAS](https://github.com/spedas/pyspedas): Python-based Space Physics Environment Data Analysis Software.

## Demo

Load and plot THEMIS FGM data.

```julia
using PySPEDAS

trange=["2007-03-23", "2007-03-24"]
# Load THEMIS FGM data for probe A
fgm_vars = pyspedas.projects.themis.fgm(probe='a', trange=trange)
# Print the list of tplot variables just loaded
println(fgm_vars)
# Plot the 'tha_fgl_dsl' variable
tplot("tha_fgl_dsl")
```

You can load projects into scope for quick access:

```julia
using PySPEDAS.Projects

trange=["2020-04-20/06:00", "2020-04-20/08:00"]
# Then you can use them directly
mms.fgm(trange, time_clip=true, probe=2)
```