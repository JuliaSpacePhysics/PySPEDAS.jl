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

struct TplotVariable{T,N} <: AbstractDataVariable{T,N}
    name::Symbol
    data::PyArray{T,N}
    py::Py
end

function TplotVariable(name)
    py = pytplot.data_quants[String(name)]
    data = PyArray(py.data; copy=false)
    TplotVariable(Symbol(name), data, py)
end

SpaceDataModel.times(var::TplotVariable) = pyconvert_time(var.py.time.data)

struct LoadFunction
    py::Py
end

function (f::LoadFunction)(args...; kwargs...)
    tvars_py = f.py(args...; kwargs...)
    tvars = pyconvert(Vector{Symbol}, tvars_py)
    NamedTuple{tuple(tvars...)}(TplotVariable.(tvars))
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
    println(io, "Tplot Variable: $(var.name)")
    show(io, m, var.py)
end