using BenchmarkTools
using PySPEDAS
using DimensionalData

const SUITE = BenchmarkGroup()

pyspedas.projects.omni.data(; trange = ["2017-03-23/00:00:00", "2017-03-23/23:59:59"])
pyspedas.projects.mms.fpi(; trange = ["2015-10-16/04:00", "2015-10-16/04:10"], datatype = "des-moms")

# 1-D; time × energy with time-varying bins; time × 3 × 3
for name in ("SYM_H", "mms1_des_energyspectr_omni_fast", "mms1_des_temptensor_gse_fast")
    g = SUITE[name] = BenchmarkGroup()
    g["get_data"] = @benchmarkable get_data($name)
    g["DimArray"] = @benchmarkable DimArray(var) setup = (var = get_data($name))
    g["DimArray(get_data)"] = @benchmarkable DimArray(get_data($name))
end
SUITE["SYM_H"]["collect"] = @benchmarkable collect(var) setup = (var = get_data("SYM_H"))
