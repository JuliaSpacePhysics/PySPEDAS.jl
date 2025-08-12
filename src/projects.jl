# Pre-declare the constants for all known projects
# https://github.com/spedas/pyspedas/blob/master/pyspedas/projects/__init__.py
const PROJECTS = [:ace, :akebono, :barrel, :cluster, :cnofs, :csswe, :de2, :dscovr, :elfin, :equator_s, :erg, :fast, :geotail, :goes, :image, :kompsat, :kyoto, :lanl, :maven, :mica, :mms, :noaa, :omni, :poes, :polar, :psp, :rbsp, :secs, :soho, :solo, :st5, :stereo, :swarm, :themis, :twins, :ulysses, :wind]

is_public_attribute(name) = !startswith(string(name), "__")

"""
Filter out Python dunder attributes (those that start with "__")
"""
function projects()
    filter(is_public_attribute, propertynames(pyspedas.projects)) |> sort
end

# Handful module for exporting projects
module Projects
using PythonCall
using ..PySPEDAS
using ..PySPEDAS: PROJECTS, is_public_attribute
for p in PROJECTS
    @eval const $p = Project($(QuoteNode(p)))
    @eval export $p
end

function __init__()
    for p in PROJECTS
        try
            pym = pyimport("pyspedas.projects.$(p)")
            @eval PythonCall.pycopy!($p.py, $pym)
            @eval $p.attributes[] = filter(is_public_attribute, propertynames($p.py))
        catch e
            @warn "Failed to load project $(p): $e"
        end
    end
    return
end
end