using TestItems, TestItemRunner

@testitem "Aqua" begin
    using Aqua
    Aqua.test_all(PySPEDAS)
end

@testitem "PySPEDAS.jl" begin
    @test_nowarn PySPEDAS.demo_get_data()
end
