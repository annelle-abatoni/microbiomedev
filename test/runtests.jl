using Test
using Microbiome


@testset "find clade" begin
    @test findClade("k__Bacteria", :kingdom) == Taxon("Bacteria", :kingdom)
    @test findClade("k__Bacteria|p__Firmicutes", :kingdom) == Taxon("Bacteria", :kingdom)
    @test findClade("k__Bacteria|p__Firmicutes", :phylum) == Taxon("Firmicutes", :phylum)
    @test findClade("k__Bacteria|p__Firmicutes__blah", :phylum) == error("incorrectly formatted name string: p__Firmicutes__blah")
    @test findClade("k__Bacteria|oickles", :phylum) ==  error("incorrectly formatted name string: oickles")
end



