using TestItems, TestItemRunner

@run_package_tests filter = ti -> !(:skipci in ti.tags)

@testitem "Aqua" begin
    using Aqua
    Aqua.test_all(PySPEDAS)
end

@testitem "PySPEDAS.jl" begin
    using PySPEDAS: XArrayDataArray

    var = PySPEDAS.demo_get_data()
    @test var.dims == ("time",)
    coord = PySPEDAS.coordinate(var, "time")
    @test coord isa XArrayDataArray
    @test coord.dims == ("time",)

    using PySPEDAS.Projects
    @test themis.fgm(["2020-04-20/06:00", "2020-04-20/08:00"], time_clip = true, probe = "d")[1] isa XArrayDataArray
end

@testitem "Project initialization" begin
    using PySPEDAS: Projects, _init_projects

    # Test that project initialization works without @eval issues
    @test_nowarn _init_projects()

    # Test that projects are properly initialized
    @test isdefined(Projects, :wind)
    @test Projects.wind isa PySPEDAS.Project
    @test Projects.wind.name == :wind

    # Test that project attributes are initialized
    @test Projects.wind.attributes[] isa Vector{Symbol}
    @test !isempty(Projects.wind.attributes[])
end


@testitem "PySPEDASSchema (1D)" begin
    using PySPEDAS: PySPEDASSchema, get_data, pyspedas
    using SpaceDataModel: get_schema

    pyspedas.projects.omni.data(; trange = ["2017-03-23/00:00:00", "2017-03-23/01:00:00"])
    var = get_data("SYM_H")
    schema = get_schema(var)
    @test schema isa PySPEDASSchema

    attrs = schema(var)
    @test attrs[:long_name] == "SYM/H index"
    @test attrs[:desc] == "SYM/H - 1-minute SYM/H index,from WDC Kyoto (1981/001-2024/244)"
    @test attrs[:name] == "SYM/H index"
    @test attrs[:unit] == "nT"
end

@testitem "PySPEDASSchema (2D, depend_1)" begin
    using PySPEDAS: PySPEDASSchema, get_data, pyspedas
    using SpaceDataModel: get_schema

    pyspedas.projects.themis.fgm(;
        trange = ["2020-04-20/06:00", "2020-04-20/06:05"],
        probe = "d",
        time_clip = true,
    )
    var = get_data("thd_fgs_gsm")
    schema = get_schema(var)
    attrs = schema(var)
    @test attrs[:desc] == "FGS magnetic field B in XYZ GSM Coordinates"
    @test attrs[:unit] == attrs[:depend_1_unit] == "nT GSM"
    @test attrs[:labels] == ["Bx FGS-D", "By FGS-D", "Bz FGS-D"]
    @test attrs[:depend_1_name] == "THD FGS"
    @test attrs[:depend_1_scale] == "linear"
end

@testitem "MMS FPI multidimensional data" begin
    using DimensionalData
    using PySPEDAS: get_data, pyspedas

    pyspedas.projects.mms.fpi(;
        trange = ["2015-10-16/04:00", "2015-10-16/04:10"],
        datatype = "des-moms",
    )

    spectr = get_data("mms1_des_energyspectr_omni_fast")
    @test spectr.dims == ("time", "v_dim")
    @test size(spectr, 2) == 32
    @test PySPEDAS.coordinate(spectr, "spec_bins").dims == ("time", "v_dim")
    @test DimArray(spectr) isa DimArray

    tensor = get_data("mms1_des_temptensor_gse_fast")
    @test tensor.dims == ("time", "v1_dim", "v2_dim")
    @test size(tensor)[2:3] == (3, 3)
    @test DimArray(tensor) isa DimArray
end
