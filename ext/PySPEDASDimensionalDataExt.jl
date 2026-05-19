module PySPEDASDimensionalDataExt

using DimensionalData
import DimensionalData: DimArray, dims
import PySPEDAS
using PySPEDAS: XArrayDataArray
using SpaceDataModel: getmeta, dim

import Base: convert

# DimensionalData.dims only support 1D dimensions
function DimensionalData.dims(var::XArrayDataArray, i::Int)
    dimvar = dim(var, i)
    name = PySPEDAS.dimnames(var, i)
    return Dim{Symbol(name)}(length(dimvar) == size(var, i) ? dimvar : axes(dimvar, i))
end

DimensionalData.dims(var::XArrayDataArray) = ntuple(i -> dims(var, i), ndims(var))

function DimensionalData.DimArray(var::XArrayDataArray; kw...)
    return DimArray(parent(var), dims(var); name = var.name, metadata = getmeta(var), kw...)
end

Base.convert(::Type{T}, var::XArrayDataArray) where {T <: AbstractDimArray} = T(var)

end
