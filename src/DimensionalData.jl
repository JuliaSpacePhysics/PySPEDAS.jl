using DimensionalData
import DimensionalData: dims, DimArray
using DimensionalData.Lookups: NoLookup
import Base: convert

is_datetime64_ns(py) = pyeq(Bool, py.dtype, @pyconst(np.dtype("datetime64[ns]")))

"""
Get the dimensions of a tplot variable from the underlying `xarray.DataArray`.

# Reference:
- https://github.com/rafaqz/DimensionalData.jl/blob/main/ext/DimensionalDataPythonCall.jl
"""
function get_xarray_dims(var)
    x = var.py
    dim_names = NTuple{ndims(var)}(Symbol(d) for d in x."dims")
    coord_names = Tuple(Symbol(d) for d in x."coords"."keys"())
    return map(dim_names) do dim
        lookup = if dim == :time
            pyconvert_time(x."time"."data")
        elseif dim == :v_dim && hasproperty(x, :v)
            PyArray(x."v"."data"; copy = false)
        elseif dim in coord_names
            PyArray(getproperty(x, dim)."data"; copy = false)
        else
            NoLookup()
        end
        Dim{dim}(lookup)
    end
end

DimensionalData.dims(v::TplotVariable) = Tuple(get_xarray_dims(v))

# https://discourse.julialang.org/t/convert-vs-constructors/4159
function DimensionalData.DimArray(var::TplotVariable; kw...)
    return DimArray(var.data, dims(var); name = var.name, metadata = var.metadata, kw...)
end

Base.convert(::Type{T}, var::TplotVariable) where {T <: AbstractDimArray} = T(var)
