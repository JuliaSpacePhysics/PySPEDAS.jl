module PySPEDAS

using PythonCall
using PythonCall: pynew
using DimensionalData
using Dates
import DimensionalData: DimArray
import DimensionalData.Lookups: NoLookup

export pyspedas, pytplot
export tplot, get_data
export Project, TplotVariable

include("types.jl")
include("utils.jl")
include("projects.jl")

using .Projects

const TnamesType = Union{AbstractArray,Tuple}

const pyspedas = pynew()
const pytplot = pynew()

function __init__()
    PythonCall.pycopy!(pyspedas, pyimport("pyspedas"))
    PythonCall.pycopy!(pytplot, pyimport("pytplot"))
    for p in PROJECTS
        try
            project = @eval $p
            PythonCall.pycopy!(project.py, pyimport("pyspedas.projects.$(p)"))
            project.attributes[] = filter(is_public_attribute, propertynames(project.py))
        catch e
            @warn "Failed to load project $(p): $e"
        end
    end
end

tplot(args...) = @pyconst(pyspedas.tplot)(args...)
tplot(tnames::TnamesType, args...) = @pyconst(pyspedas.tplot)(pylist(tnames), args...)

get_data(name; xarray=true, kwargs...) = pyspedas.get_data(name; xarray, kwargs...)

function demo(; trange=["2020-04-20/06:00", "2020-04-20/08:00"])
    pyspedas.projects.solo.mag(; trange, time_clip=true)
    pyspedas.projects.psp.fields(; trange, time_clip=true)
    pyspedas.projects.mms.fgm(; trange, time_clip=true, probe=2)
    pyspedas.projects.themis.fgm(; trange, time_clip=true, probe='d')
    tplot(["B_RTN", "psp_fld_l2_mag_RTN", "mms2_fgm_b_gsm_srvy_l2_bvec", "thd_fgs_gsm"])
end

end
