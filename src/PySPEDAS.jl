module PySPEDAS

using PythonCall
using DimensionalData
using Dates
import DimensionalData.Lookups: NoLookup

export pyspedas
export mms, themis
export tplot

include("utils.jl")

const TnamesType = Union{AbstractArray,Tuple}

const pyspedas = PythonCall.pynew()
const mms = PythonCall.pynew()
const themis = PythonCall.pynew()

function __init__()
    PythonCall.pycopy!(pyspedas, pyimport("pyspedas"))
    PythonCall.pycopy!(mms, pyimport("pyspedas.projects.mms"))
    PythonCall.pycopy!(themis, pyimport("pyspedas.projects.themis"))
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

"""Load and plot THEMIS FGM data"""
function themis_demo(; trange=["2007-03-23", "2007-03-24"])
    # Load THEMIS FGM data for probe A
    fgm_vars = themis.fgm(probe='a', trange=trange)
    # Print the list of tplot variables just loaded
    println(fgm_vars)
    # Plot the 'tha_fgl_dsl' variable
    tplot("tha_fgl_dsl")
end

function demo(; trange=["2020-04-20/06:00", "2020-04-20/08:00"])
    pyspedas.projects.solo.mag(; trange, time_clip=true)
    pyspedas.projects.psp.fields(; trange, time_clip=true)
    pyspedas.projects.mms.fgm(; trange, time_clip=true, probe=2)
    pyspedas.projects.themis.fgm(; trange, time_clip=true, probe='d')
    tplot(["B_RTN", "psp_fld_l2_mag_RTN", "mms2_fgm_b_gsm_srvy_l2_bvec", "thd_fgs_gsm"])
end

end
