"""
    pyconvert_time(time)

Convert `time` from Python to Julia.

Much faster than `pyconvert(Array, time)`
"""
function pyconvert_time(times)
    @assert is_datetime64_ns(times)
    py_ns = PyArray{Int64, 1, true, true, Int64}(times."view"("i8"), copy = false)
    return length(py_ns) == 0 ? UnixTime[] : reinterpret(UnixTime, py_ns)
end

"""
    promote_cdf_attributes!(meta)

Promotes the nested CDF variable attributes to the top level of the metadata.
"""
function promote_cdf_attributes!(meta)
    cdf_attrs = meta["CDF"]["VATT"]
    for (k, v) in cdf_attrs
        meta[k] = v
    end
    return
end
