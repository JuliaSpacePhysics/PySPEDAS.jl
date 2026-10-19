import PythonCall: pycopy!

struct PythonModule{A}
    mod::PythonCall.Py
    autoimports::A
end

PythonModule(mod) = PythonModule(mod, ())

PythonCall.pycopy!(dst::PythonModule, src) = pycopy!(dst.mod, src)
PythonCall.Py(mod::PythonModule) = getfield(mod, :mod)

@inline function Base.getproperty(m::PythonModule, name::Symbol)
    name in fieldnames(PythonModule) && return getfield(m, name)
    py = Py(m)
    name in m.autoimports && return pyimport("$(py.__name__).$name")
    return getproperty(py, name)
end

abstract type Module end

function attributes end

Base.propertynames(p::Module) = attributes(p)

struct Project <: Module
    name::Symbol
    py::Py
    attributes::Ref{Vector{Symbol}}
end

Project(name) = Project(name, pynew(), Ref{Vector{Symbol}}())

# This somehow could prevent the Segmentation fault, see also https://github.com/JuliaPy/PythonCall.jl/issues/586
attributes(p::Project) = p.attributes[]

# `py` is read once at construction: Julia-side queries never call Python. A coordinate is a `DataVariable` of its xarray `Variable`.
struct XArrayDataArray{T, N, V <: DataVariable{T, N}} <: AbstractDataVariable{T, N}
    dv::V
    py::Py
end

function XArrayDataArray(py; name = nothing, attrs = nothing)
    name = @something name pyconvert(Any, @py py.name) ""
    attrs = @something attrs PyDict{String, Any}(@py py.attrs)
    return XArrayDataArray(_datavariable(py, name, attrs), py)
end

SpaceDataModel.DataVariable(var::XArrayDataArray) = getfield(var, :dv)
Base.parent(var::XArrayDataArray) = parent(DataVariable(var))
SpaceDataModel.getmeta(var::XArrayDataArray) = getmeta(DataVariable(var))
SpaceDataModel.name(var::XArrayDataArray) = name(DataVariable(var))
SpaceDataModel.dims(var::XArrayDataArray, i::Integer) = dims(DataVariable(var), i)
SpaceDataModel.tdimnum(var::XArrayDataArray) = tdimnum(DataVariable(var))
SpaceDataModel.coords(var::XArrayDataArray) = coords(DataVariable(var))

@inline function Base.getproperty(var::XArrayDataArray, s::Symbol)
    s in fieldnames(XArrayDataArray) && return getfield(var, s)
    s == :data && return parent(var)
    s == :name && return name(var)
    s in (:attrs, :metadata) && return getmeta(var)
    s == :dims && return dimnames(var)
    return getproperty(var.py, s)
end

const TplotVariable = XArrayDataArray

struct LoadFunction
    py::Py
end

function (f::LoadFunction)(args...; kwargs...)
    tvars_py = f.py(args...; kwargs...)
    tvars = Tuple(pyconvert(Vector{Symbol}, tvars_py))
    return NamedTuple{tvars}(get_data.(tvars))
end

# Allow calling methods on the Python module
function Base.getproperty(p::Project, s::Symbol)
    if s in fieldnames(Project)
        return getfield(p, s)
    else
        attr = getproperty(getfield(p, :py), s)
        return pycallable(attr) ? LoadFunction(attr) : attr
    end
end

# Show the project name
Base.show(io::IO, p::Project) = print(io, "SPEDAS Project: $(p.name)")
Base.show(io::IO, var::TplotVariable) = print(io, var.py.data)
function Base.show(io::IO, m::MIME"text/plain", var::TplotVariable)
    println(io, "XArray DataArray: $(var.name)")
    return show(io, m, var.py)
end
