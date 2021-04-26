using Test
using Microbiome


@testset "find clade" begin
    @test findClade("k__Bacteria", :kingdom) == Taxon("Bacteria", :kingdom)
    @test findClade("k__Bacteria|p__Firmicutes", :kingdom) == Taxon("Bacteria", :kingdom)
    @test findClade("k__Bacteria|p__Firmicutes", :phylum) == Taxon("Firmicutes", :phylum)
end

@testset "Test tests" begin
    @test 1 == 1
    @test occursin("blah", "blah blah")
    @test 1 == 2
end

