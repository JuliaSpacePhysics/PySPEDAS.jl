using DimensionalData
import DimensionalData: DimArray, dims
import DimensionalData.Lookups: NoLookup

function get_xarray_dims(x; transpose = false)
    dim_names = tuple(Symbol.(collect(x.dims))...)
    dim_names = transpose ? reverse(dim_names) : dim_names
    coord_names = Symbol.(collect(x.coords.keys()))
    lookups_values = map(dim_names) do dim
        if dim in coord_names
            coord_py = getproperty(x, dim).data
            coord_type = string(coord_py.dtype.name)
            coord = coord_type == "datetime64[ns]" ? pyconvert_time(coord_py) : PyArray(coord_py; copy = false)
            Dim{dim}(coord)
        else
            Dim{dim}(NoLookup())
        end
    end
    return lookups_values
end

DimensionalData.dims(v::TplotVariable) = Tuple(get_xarray_dims(v.py))

"""
    get_data(::Type{DimArray}, name; kwargs...)

Retrieve data from a tplot variable and convert it to a `DimensionalData.DimArray.
"""
get_data(::Type{DimArray}, name; kwargs...) = pyconvert_dataarray(get_data(name; kwargs...))

"""
    get_data(::Type{T<:AbstractDimStack}, names; kwargs...)

Retrieve multiple tplot variables and combine them into a DimensionalData stack.
"""
function get_data(::Type{T}, names; kwargs...) where {T <: AbstractDimStack}
    return T(pyconvert_dataarray.(get_data.(names; kwargs...)))
end

function DimensionalData.DimArray(var::TplotVariable; kwargs...)
    return pyconvert_dataarray(var.py; kwargs...)
end

"""
    pyconvert_dataarray(x; transpose=false)

Convert a `xarray.DataArray` to a `DimensionalData.DataArray`.

# Reference:
- https://github.com/rafaqz/DimensionalData.jl/blob/main/ext/DimensionalDataPythonCall.jl
"""
function pyconvert_dataarray(x; transpose = false)
    data_npy = transpose ? x.data.T : x.data
    data = PyArray(data_npy; copy = false)

    dims = get_xarray_dims(x; transpose)
    metadata = pyconvert(Dict{Any, Any}, x.attrs)
    array_name = pyis(x.name, pybuiltins.None) ? nothing : string(x.name)

    return DimArray(data, dims; name = array_name, metadata)
end
