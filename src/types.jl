"""
    Project

Represents a SPEDAS project with a Python module reference.
"""
struct Project
    name::Symbol
    pymodule::PythonCall.Py

    function Project(name::Symbol)
        new(name, PythonCall.pynew())
    end
end

struct LoadFunction
    py::Py
end

(f::LoadFunction)(args...; kwargs...) = f.py(args...; kwargs...)


# Allow calling methods on the Python module
function Base.getproperty(p::Project, s::Symbol)
    if s in fieldnames(Project)
        return getfield(p, s)
    else
        return LoadFunction(getproperty(getfield(p, :pymodule), s))
    end
end

# Show the project name
Base.show(io::IO, p::Project) = print(io, "SPEDAS Project: $(p.name)")