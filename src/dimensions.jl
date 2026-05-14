function coordinate(var::XArrayDataArray, i::Integer)
    py = var.py
    name = @py(py.dims)[i - 1]
    coords = @py py.coords
    pyin(name, coords) && return XArrayDataArray(coords[name])
    for coord in @py coords.values()
        pyin(name, coord.dims) && return XArrayDataArray(coord)
    end
    return nothing
end

function coordinate(var::XArrayDataArray, name)
    py = var.py
    return XArrayDataArray(@py py.coords[name])
end

function SpaceDataModel.dim(var::XArrayDataArray, i::Integer)
    coord = coordinate(var, i)
    return isnothing(coord) ? axes(var, i) : coord
end

function dimnames(var::XArrayDataArray, i::Integer)
    py = var.py
    return pyconvert(String, @py(py.dims)[i - 1])
end

function dimname(var::XArrayDataArray)
    py = var.py
    T = NTuple{ndims(var), String}
    return pyconvert(T, @py py.dims)
end

function SpaceDataModel.tdimnum(var::XArrayDataArray)
    i = findfirst(==("time"), var.dims)
    return isnothing(i) ? ndims(var) : i
end

function _xarray_values(py)
    data = @py py.data
    return is_datetime64_ns(data) ? pyconvert_time(data) : PyArray(data; copy = false)
end
