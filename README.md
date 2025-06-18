# PySPEDAS.jl

[![Build Status](https://github.com/Beforerr/PySPEDAS.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Beforerr/PySPEDAS.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A Julia wrapper around [PySPEDAS](https://github.com/spedas/pyspedas): Python-based Space Physics Environment Data Analysis Software.

## Installation

```julia
using Pkg
Pkg.add("PySPEDAS")
```

## Demo

Load and plot THEMIS FGM data.

```julia
using PySPEDAS
using DimensionalData

trange=["2007-03-23", "2007-03-24"]
# Load THEMIS FGM data for probe A
fgm_vars = pyspedas.projects.themis.fgm(probe='a', trange=trange)
# Print the list of tplot variables just loaded
println(fgm_vars)

# Retrieve the 'tha_fgl_dsl' variable as a `DimArray` similar to `xarray`
get_data(DimArray, "tha_fgl_dsl")

# Plot the 'tha_fgl_dsl' variable using PySPEDAS's `tplot` function (`matplotlib`)
pytplot("tha_fgl_dsl")
```

You can load projects into scope for quick access:

```julia
using PySPEDAS.Projects

trange=["2020-04-20/06:00", "2020-04-20/08:00"]
# Then you can use them directly
mms.fgm(trange, time_clip=true, probe=2)
```

Each mission is represented as a `Project` type, which wraps the underlying Python module.

> [!NOTE]
> [SPEDAS.jl](https://github.com/Beforerr/SPEDAS.jl) provides a native Julia counterpart with cross-language validation and comparison. See [SPEDAS.jl Documentation](https://beforerr.github.io/SPEDAS.jl/dev/validation/pyspedas/) for more details.
