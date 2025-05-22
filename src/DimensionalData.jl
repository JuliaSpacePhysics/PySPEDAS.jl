using DimensionalData
import DimensionalData: DimArray
import DimensionalData.Lookups: NoLookup

function DimensionalData.DimArray(var::TplotVariable; kwargs...)
    pyconvert_dataarray(var.py; kwargs...)
end

"""
    pyconvert_dataarray(x; transpose=false)

Convert a `xarray.DataArray` to a `DimensionalData.DataArray`.

# Reference:
- https://github.com/rafaqz/DimensionalData.jl/blob/main/ext/DimensionalDataPythonCall.jl
"""
function pyconvert_dataarray(x; transpose=false)
    data_npy = transpose ? x.data.T : x.data
    data = PyArray(data_npy; copy=false)

    dim_names = tuple(Symbol.(collect(x.dims))...)
    dim_names = transpose ? reverse(dim_names) : dim_names
    coord_names = Symbol.(collect(x.coords.keys()))
    lookups_values = map(dim_names) do dim
        if dim in coord_names
            coord_py = getproperty(x, dim).data
            coord_type = string(coord_py.dtype.name)
            coord_type == "datetime64[ns]" ? pyconvert_time(coord_py) : PyArray(coord_py; copy=false)
        else
            NoLookup()
        end
    end

    lookups = NamedTuple{dim_names}(lookups_values)
    metadata = pyconvert(Dict{Any,Any}, x.attrs)
    array_name = pyis(x.name, pybuiltins.None) ? nothing : string(x.name)

    return DimArray(data, lookups; name=array_name, metadata)
end