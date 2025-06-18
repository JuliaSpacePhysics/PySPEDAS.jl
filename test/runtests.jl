using TestItems, TestItemRunner

@run_package_tests filter = ti -> !(:skipci in ti.tags)

@testitem "Aqua" begin
    using Aqua
    Aqua.test_all(PySPEDAS)
end

@testitem "PySPEDAS.jl" begin
    using PySPEDAS.DimensionalData
    @test PySPEDAS.demo_get_data() isa DimArray
end
