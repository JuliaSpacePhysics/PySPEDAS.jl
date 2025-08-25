using DimensionalData
import DimensionalData: dims, DimArray
using DimensionalData.Lookups: NoLookup
import Base: convert

is_datetime64_ns(py) = string(py.dtype.name) == "datetime64[ns]"

"""
Get the dimensions of a tplot variable from the underlying `xarray.DataArray`.

# Reference:
- https://github.com/rafaqz/DimensionalData.jl/blob/main/ext/DimensionalDataPythonCall.jl
"""
function get_xarray_dims(x; transpose = false)
    dim_names = tuple(Symbol.(collect(x.dims))...)
    dim_names = transpose ? reverse(dim_names) : dim_names
    coord_names = Symbol.(collect(x.coords.keys()))
    lookups_values = map(dim_names) do dim
        lookup = if dim in coord_names
            coord_py = getproperty(x, dim).data
            is_datetime64_ns(coord_py) ? pyconvert_time(coord_py) : PyArray(coord_py; copy = false)
        elseif dim == :v_dim && hasproperty(x, :v)
            PyArray(x.v.data; copy = false)
        else
            NoLookup()
        end
        Dim{dim}(lookup)
    end
    return lookups_values
end

DimensionalData.dims(v::TplotVariable) = Tuple(get_xarray_dims(v.py))

# https://discourse.julialang.org/t/convert-vs-constructors/4159
function DimensionalData.DimArray(var::TplotVariable; kw...) 
    return DimArray(var.data, dims(var); name = var.name, metadata = var.metadata, kw...)
end

Base.convert(::Type{T}, var::TplotVariable) where {T <: AbstractDimArray} = T(var)