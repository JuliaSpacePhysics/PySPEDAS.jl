is_datetime64_ns(py) = pyeq(Bool, @py(py.dtype), @pyconst(np.dtype("datetime64[ns]")))

"""
    pyconvert_time(time)

Convert `time` from Python to Julia.

Much faster than `pyconvert(Array, time)`
"""
function pyconvert_time(times)
    @assert is_datetime64_ns(times)
    py_ns = PyArray{Int64, 1, false, true, Int64}(times."view"("i8"), copy = false)
    return length(py_ns) == 0 ? UnixTime[] : reinterpret(UnixTime, py_ns)
end
