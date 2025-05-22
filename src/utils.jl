# https://github.com/JuliaPy/PythonCall.jl/pull/509
convert_time(::Type{<:DateTime}, t::Py) = DateTime(pyconvert(String, pystr(t.astype("datetime64[ms]")))) # pyconvert(DateTime, pyt0.astype("datetime64[ms]").item()) # slower

"""
    pyconvert_time(time)

Convert `time` from Python to Julia.

Much faster than `pyconvert(Array, time)`
"""
function pyconvert_time(time)
    if length(time) == 0
        return DateTime[]
    end
    dt_min = Nanosecond(1)
    pyt0 = time[0]
    t0 = convert_time(DateTime, pyt0)
    dt_f = PyArray((time - pyt0) / pyns; copy=false)
    return t0 .+ dt_f .* dt_min
end