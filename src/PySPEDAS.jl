module PySPEDAS

using PythonCall
using DimensionalData
using Dates
import DimensionalData.Lookups: NoLookup

export pyspedas
export tplot, get_data

include("utils.jl")
include("projects.jl")

using .Projects

const TnamesType = Union{AbstractArray,Tuple}

const pyspedas = PythonCall.pynew()

function __init__()
    PythonCall.pycopy!(pyspedas, pyimport("pyspedas"))
    for p in Projects.PROJECTS
        try
            project = @eval Projects.$p
            PythonCall.pycopy!(project, pyimport("pyspedas.projects.$p"))
        catch e
            @warn "Failed to load project $p: $e"
        end
    end
end

tplot(args...) = @pyconst(pyspedas.tplot)(args...)
tplot(tnames::TnamesType, args...) = @pyconst(pyspedas.tplot)(pylist(tnames), args...)

"""
    get_data(name)

Convert a tplot variable `name` from Python to a `DimensionalData.DataArray` in Julia.
"""
function get_data(name; transpose=false)
    x = pyspedas.get_data(name; xarray=true)
    pyconvert_dataarray(x; transpose)
end

function demo(; trange=["2020-04-20/06:00", "2020-04-20/08:00"])
    pyspedas.projects.solo.mag(; trange, time_clip=true)
    pyspedas.projects.psp.fields(; trange, time_clip=true)
    pyspedas.projects.mms.fgm(; trange, time_clip=true, probe=2)
    pyspedas.projects.themis.fgm(; trange, time_clip=true, probe='d')
    tplot(["B_RTN", "psp_fld_l2_mag_RTN", "mms2_fgm_b_gsm_srvy_l2_bvec", "thd_fgs_gsm"])
end

end
