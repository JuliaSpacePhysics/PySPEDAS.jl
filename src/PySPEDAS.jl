module PySPEDAS

using PythonCall
using PythonCall: pynew
using Dates
using SpaceDataModel
using SpaceDataModel: AbstractDataVariable
import SpaceDataModel: times

export pyspedas, pytplot
export tplot, get_data
export Project, TplotVariable

include("types.jl")
include("utils.jl")
include("projects.jl")
include("DimensionalData.jl")

using .Projects

const TnamesType = Union{AbstractArray,Tuple}

const pyspedas = pynew()
const pytplot = pynew()
const pyns = pynew()

function __init__()
    PythonCall.pycopy!(pyspedas, pyimport("pyspedas"))
    PythonCall.pycopy!(pytplot, pyimport("pytplot"))
    PythonCall.pycopy!(pyns, pyimport("numpy").timedelta64(1, "ns"))
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

"""
    get_data(name; xarray=true, kwargs...)

Retrieve data from a tplot variable by `name`.

By default, returns an xarray DataArray object. If `xarray` is set to false, returns a tuple of (times, data).
"""
get_data(name; xarray=true, kwargs...) = pyspedas.get_data(name; xarray, kwargs...)

"""
    get_data(::Type{DimArray}, name; kwargs...)

Retrieve data from a tplot variable and convert it to a `DimensionalData.DimArray.
"""
get_data(::Type{DimArray}, name; kwargs...) = pyconvert_dataarray(get_data(name; kwargs...))

"""
    get_data(::Type{T<:AbstractDimStack}, names; kwargs...)

Retrieve multiple tplot variables and combine them into a DimensionalData stack.
"""
function get_data(::Type{T}, names; kwargs...) where {T<:AbstractDimStack}
    T(pyconvert_dataarray.(get_data.(names; kwargs...)))
end

function demo_get_data(; trange=["2020-04-20/06:00", "2020-04-20/08:00"])
    pyspedas.projects.themis.fgm(; trange, time_clip=true, probe='d')
    get_data(DimArray, "thd_fgs_gsm")
end

function demo(; trange=["2020-04-20/06:00", "2020-04-20/08:00"])
    pyspedas.projects.solo.mag(; trange, time_clip=true)
    pyspedas.projects.psp.fields(; trange, time_clip=true)
    pyspedas.projects.mms.fgm(; trange, time_clip=true, probe=2)
    pyspedas.projects.themis.fgm(; trange, time_clip=true, probe='d')
    tplot(["B_RTN", "psp_fld_l2_mag_RTN", "mms2_fgm_b_gsm_srvy_l2_bvec", "thd_fgs_gsm"])
end

end
