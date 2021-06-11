using Pkg
Pkg.activate(@__DIR__)
Pkg.add("Dictionaries")

using DataFrames
using CSV
using Microbiome
using SparseArrays
using Dictionaries

p1 = CSV.read("profiles/C0043-7F-1A_S14_profile.tsv", DataFrame, delim='\t',
    header=["taxon", "taxid", "abundance", "additional"], datarow = 5)
p2 = CSV.read("profiles/C0052-5F-1A_S49_profile.tsv", DataFrame, delim='\t',
    header=["taxon", "taxid", "abundance", "additional"], datarow = 5)
p3 = CSV.read("profiles/C0053-6F-1A_S61_profile.tsv", DataFrame, delim='\t',
    header=["taxon", "taxid", "abundance", "additional"], datarow = 5)


select!(p1, ["taxon", "abundance"])
select!(p2, ["taxon", "abundance"])
select!(p3, ["taxon", "abundance"])

rename!(p1, "abundance" => "C0043-7F-1A")
rename!(p2, "abundance" => "C0052-5F-1A")
rename!(p3, "abundance" => "C0053-6F-1A")

profiles = outerjoin(p1, p2, p3, on=:taxon)

taxa = Taxon.(profiles.taxon)
samples = MicrobiomeSample.(names(profiles)[2:end])

abund = Matrix(select(profiles, Not("taxon")))
abund = coalesce.(abund, 0.) #turns all missings to 0

# sparse turns matrix into sparse matrix
# using SparseArrays 
cp = CommunityProfile(sparse(abund), taxa, samples)

# TODO: make function that turns string, eg "k__Bacteria|p__Firmicutes|c__Clostridia"
# into a `Taxon` type with correct name and clade, eg `Taxon("Clostricia, :class)`

a = split("k__Bacteria|p__Firmicutes|c__Clo","|")

# anonymous function syntax: `arg -> func(arg)`
# instead of:
startswith_k(str) = startswith(str, "k")
findfirst(startswith_k, a)

startswith_p(str) = startswith(str, "p")
findfirst(startswith_p, a)

startswith_c(str) = startswith(str, "c")
findfirst(startswith_c, a)

# with annonymous function
findfirst(astr -> startswith(str, "c"), a)

# with do syntax
findfirst(a) do str
    startswith(str, "c")
end

# functions that take functions as first arguments, eg
# map, findall, findfirst

# TO DO: find level, gets level (eg. class) as argument

const _taxon_conversion = (k = :kingdom, 
                    p = :phylum, 
                    c = :class,
                    o = :order,
                    f = :family,
                    g = :genus,
                    s = :species)

                    
function _get_taxon(elt)
           pieces = split(elt, "__")
           length(pieces) == 2 || error("incorrectly formatted name string: $elt")
           (lev, name) = pieces
           lev_abr = Symbol(lev)
           lev_abr in keys(taxon_conversion) || error("Invalid taxon abbreviation: $lev_abr in name $elt")
           return Taxon(name, taxon_conversion[lev_abr])
       end



function findClade(str, desiredClade)
    splitStr = split(str, "|")
    for elt in splitStr
        t = _get_taxon(elt)

        if desiredClade == clade(t)
            return t
        end
    end
end

# function findClade(str, desiredClade) 
#     splitStr = split(str, "|")
#     #add error if desiredclade
#     for elt in splitStr
#         lev_abr = Symbol(first(elt))
#         if desiredClade == taxon_conversion[lev_abr] 
#             name = elt[4:end]
#             return(Taxon(name, taxon_conversion[lev_abr]))
#         #else, return nothing if str doesn't contain desiredClade
#         end
#     end
# end