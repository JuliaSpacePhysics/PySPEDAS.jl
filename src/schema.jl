using SpaceDataModel: MetadataSchema, SchemaDict, Via
using SpaceDataModel: getmeta
import SpaceDataModel: rules, resolve

"""
    PySPEDASSchema <: MetadataSchema

Schema for pyspedas-loaded variables. Metadata is nested as `CDF` → `VATT`
holding ISTP-style variable attributes.
"""
struct PySPEDASSchema <: MetadataSchema end

_get(x, key) = isnothing(x) ? nothing : get(x, key, nothing)

cdf(x) = _get(getmeta(x), "CDF")
vatt(x) = _get(cdf(x), "VATT")::PyDict{Any, Any}

struct Path{Ks}
    keys::Ks
end

Path(ks...) = Path(ks)

const _PYSPEDAS_SCHEMA = (
    desc = Via(vatt, "CATDESC"),
    name = (Via(vatt, "LABLAXIS"), SpaceDataModel.name),
    long_name = Via(vatt, "FIELDNAM"),
    unit = Via(vatt, "UNITS"),
    scale = Via(vatt, ("SCALETYP", "SCALE_TYP")),
    labels = Via(cdf, "LABELS"),
    display_type = Via(vatt, "DISPLAY_TYPE"),
    depend_1_name = Path("plot_options", "yaxis_opt", "axis_label"),
    depend_1_unit = Path("data_att", "depend_1_units"),
    depend_1_scale = Path("plot_options", "yaxis_opt", "y_axis_type"),
)

rules(::PySPEDASSchema) = _PYSPEDAS_SCHEMA

function resolve(data, p::Path)
    cur = data
    for k in p.keys
        isnothing(cur) && return nothing
        cur = resolve(cur, k)
    end
    return cur
end
