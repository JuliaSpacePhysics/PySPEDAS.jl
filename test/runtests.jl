using TestItems, TestItemRunner

@run_package_tests filter = ti -> !(:skipci in ti.tags)

@testitem "Aqua" begin
    using Aqua
    Aqua.test_all(PySPEDAS)
end

@testitem "PySPEDAS.jl" begin
    using PythonCall: Py
    using PySPEDAS.DimensionalData
    @test PySPEDAS.demo_get_data() isa DimArray
    @test pyspedas.geopack isa Py
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
