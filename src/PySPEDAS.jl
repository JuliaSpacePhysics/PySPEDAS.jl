module PySPEDAS

using NetCDF_jll
using PythonCall
using PythonCall: pynew
using SpaceDataModel
using SpaceDataModel: AbstractDataVariable
import SpaceDataModel: times
using UnixTimes: UnixTime
using ConcreteStructs: @concrete

export pyspedas
export pytplot, get_data
export Project, TplotVariable

include("types.jl")
include("utils.jl")
include("projects.jl")
include("DimensionalData.jl")

using .Projects

const TnamesType = Union{AbstractArray, Tuple}

const pyspedas = pynew()
const pyns = pynew()
const np = pynew()

function __init__()
    PythonCall.pycopy!(np, pyimport("numpy"))
    PythonCall.pycopy!(pyspedas, pyimport("pyspedas"))
    PythonCall.pycopy!(pyns, pyimport("numpy").timedelta64(1, "ns"))
    _init_projects()
    return
end

py_get_data(name) = @pyconst(pyspedas.get_data)(String(name); xarray = true)

function _init_projects()
    for p in PROJECTS
        try
            pym = pyimport("pyspedas.projects.$(p)")
            # Get the project instance from the Projects module
            project = getproperty(Projects, p)
            PythonCall.pycopy!(project.py, pym)
            project.attributes[] = filter(is_public_attribute, propertynames(project.py))
        catch e
            @warn "Failed to load project $(p): $e"
        end
    end
    return
end

pytplot(args...) = @pyconst(pyspedas.tplot)(args...)
pytplot(tnames::TnamesType, args...) = @pyconst(pyspedas.tplot)(pylist(tnames), args...)

"""
    get_data(name; collect = false)::TplotVariable

Retrieve data from `pyspedas` by `name`. If `collect` is true, the data will be collected into a Julia array.
"""
function get_data(name; collect = false)
    py = py_get_data(name)
    py_data = PyArray(@py py.data; copy = false)
    data = collect ? Base.collect(py_data) : py_data
    py_metadata = PyDict{String, PyDict{String, Any}}(@py py.attrs)
    metadata = Dict{Any, Any}(k => v for (k, v) in py_metadata)
    dims = get_xarray_dims(py; collect)
    return TplotVariable(name, data, dims, metadata, py)
end

function demo_get_data(; trange = ["2017-03-23/00:00:00", "2017-03-23/23:59:59"])
    pyspedas.projects.omni.data(; trange)
    return DimArray(get_data("SYM_H"))
end

function demo(; trange = ["2020-04-20/06:00", "2020-04-20/08:00"])
    pyspedas.projects.solo.mag(; trange, time_clip = true)
    pyspedas.projects.psp.fields(; trange, time_clip = true)
    pyspedas.projects.mms.fgm(; trange, time_clip = true, probe = 2)
    pyspedas.projects.themis.fgm(; trange, time_clip = true, probe = 'd')
    return pytplot(["B_RTN", "psp_fld_l2_mag_RTN", "mms2_fgm_b_gsm_srvy_l2_bvec", "thd_fgs_gsm"])
end

end
