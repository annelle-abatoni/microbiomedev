using Test
using Microbiome


@testset "find clade" begin
    @test findClade("k__Bacteria", :kingdom) == Taxon("Bacteria", :kingdom)
    @test findClade("k__Bacteria|p__Firmicutes", :kingdom) == Taxon("Bacteria", :kingdom)
    @test findClade("k__Bacteria|p__Firmicutes", :phylum) == Taxon("Firmicutes", :phylum)
end

