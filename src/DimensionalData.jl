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
    data_type = dtype2type(string(data_npy.dtype.name))
    data_ndim = pyconvert(Int, data_npy.ndim)
    data = pyconvert(Array{data_type,data_ndim}, data_npy)

    dim_names = tuple(Symbol.(collect(x.dims))...)
    dim_names = transpose ? reverse(dim_names) : dim_names
    coord_names = Symbol.(collect(x.coords.keys()))
    lookups_values = map(dim_names) do dim
        if dim in coord_names
            coord = getproperty(x, dim).data
            coord_type = dtype2type(string(coord.dtype.name))
            coord_ndim = pyconvert(Int, coord.ndim)
            coord_type == DateTime ? pyconvert_time(coord) : pyconvert(Array{coord_type,coord_ndim}, coord)
        else
            NoLookup()
        end
    end

    lookups = NamedTuple{dim_names}(lookups_values)
    metadata = pyconvert(Dict, x.attrs)
    array_name = pyis(x.name, pybuiltins.None) ? nothing : string(x.name)

    return DimArray(data, lookups; name=array_name, metadata)
end