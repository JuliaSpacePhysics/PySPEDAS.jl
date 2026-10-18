function _datavariable(py, name, attrs)
    dnames = pyconvert(Vector{String}, @py py.dims)
    variables = @py py.coords.variables
    t = findfirst(==("time"), dnames)
    tc = isnothing(t) ? nothing : _dimcoord(py, variables, dnames, t, nothing)
    return _datavariable(py, _xarray_values(py), variables, dnames, t, tc, name, attrs)
end

# Function barrier: the data and time coordinate types are known only at runtime.
function _datavariable(py, data, variables, dnames, t, tc, name, attrs)
    # The time coordinate is its own time axis; the others along time take its values as theirs.
    tkeys = isnothing(t) ? nothing : isnothing(tc) ? axes(data, t) : parent(tc)
    dims = Pair{Int, Any}[]
    for i in eachindex(dnames)
        i == t && continue
        c = _dimcoord(py, variables, dnames, i, tkeys)
        isnothing(c) || push!(dims, i => c)
    end
    time = isnothing(t) ? nothing : t => something(tc, tkeys)
    return DataVariable(data; time, dims, metadata = attrs, name)
end

# The coordinate named after dimension `i`, else the first along it alone or along it and time (time-varying bins);
# `DataVariable` holds no other shapes.
function _dimcoord(py, variables, dnames, i, tkeys)
    dname = dnames[i]
    if pyin(dname, variables)
        v = @py variables[dname]
        # An indexed coordinate's `data` rebuilds its array from the pandas index on every access.
        isindex = pyisinstance(v, @pyconst(pyimport("xarray").IndexVariable))
        return _coordinate(dname, _values(isindex ? @py(py.get_index(dname).values) : @py(v.data)), v, dnames, tkeys)
    end
    for (k, v) in @py variables.items()
        cdims = pyconvert(Vector{String}, @py v.dims)
        dname in cdims && cdims ⊆ (dname, "time") && return _coordinate(pyconvert(String, k), _xarray_values(v), v, dnames, tkeys)
    end
    return nothing
end

function _coordinate(name, values, v, dnames, tkeys)
    axs = indexin(pyconvert(Vector{String}, @py v.dims), dnames)
    issorted(axs) || (values = PermutedDimsArray(values, sortperm(axs)))
    j = findfirst(==("time"), dnames[sort(axs)])
    time = isnothing(j) ? nothing : j => something(tkeys, values)
    return DataVariable(values; time, metadata = PyDict{String, Any}(@py v.attrs), name)
end

function dimnames(var::XArrayDataArray)
    py = var.py
    T = NTuple{ndims(var), String}
    return pyconvert(T, @py py.dims)
end

_xarray_values(py) = _values(@py py.data)
_values(arr) = is_datetime64_ns(arr) ? pyconvert_time(arr) : PyArray(arr; copy = false)
