using BenchmarkTools
using PySPEDAS
using DimensionalData

const SUITE = BenchmarkGroup()

PySPEDAS.pyspedas.projects.omni.data(; trange = ["2017-03-23/00:00:00", "2017-03-23/23:59:59"])

SUITE["get_data"] = @benchmarkable get_data("SYM_H")
SUITE["get_data (collect)"] = @benchmarkable collect(get_data("SYM_H"))
SUITE["DimArray"] = @benchmarkable DimArray(var) setup = (var = get_data("SYM_H"))
