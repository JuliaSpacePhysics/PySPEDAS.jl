# https://github.com/JuliaPy/PythonCall.jl/pull/509

function dtype2type(dtype::String)
    if dtype == "float16"
        Float16
    elseif dtype == "float32"
        Float32
    elseif dtype == "float64"
        Float64
    elseif dtype == "int8"
        Int8
    elseif dtype == "int16"
        Int16
    elseif dtype == "int32"
        Int32
    elseif dtype == "int64"
        Int64
    elseif dtype == "uint8"
        UInt8
    elseif dtype == "uint16"
        UInt16
    elseif dtype == "uint32"
        UInt32
    elseif dtype == "uint64"
        UInt64
    elseif dtype == "bool"
        Bool
    elseif dtype == "datetime64[ns]"
        DateTime
    else
        error("Unsupported dtype: '$dtype'")
    end
end

"""
    pyconvert_time(time)

Convert `time` from Python to Julia.

Much faster than `pyconvert(Array, time)`
"""
function pyconvert_time(time)
    if length(time) == 0
        return DateTime[]
    end
    pydt_min = pyimport("numpy").timedelta64(1, "ns")
    dt_min = Nanosecond(1)
    pyt0 = time[0]
    t0 = pyconvert(DateTime, pyt0.astype("datetime64[s]").item()) # temporary solution, related to https://github.com/JuliaPy/PythonCall.jl/pull/509
    # t0 = pyconvert(DateTime, pyt0)
    dt_f = pyconvert(Array, (time - pyt0) / pydt_min)
    return t0 .+ dt_f .* dt_min
end