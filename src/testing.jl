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

function findClass(stringTaxon) 
    chompedStr = chomp(stringTaxon, head=12, tail=0)   
    println(chompedStr)
    for letters in chompedStr
        if !occursin(chompedStr,"|c_")
            println(letters * ": No class found")
        else
            println(letters * " : Found it!")
        end
    end
end
## DOESN'T WORK BECAUSE Taxon type WAS String instead ##

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
findfirst(str -> startswith(str, "c"), a)

# with do syntax
findfirst(a) do str
    startswith(str, "c")
end

# functions that take functions as first arguments, eg
# map, findall, findfirst

# TO DO: find level, gets level (eg. class) as argument


function findClade(stringTaxon, desiredClade) #input desiredClade eg. kingdom, phylum class
    desiredClade = lowercase(desiredClade)
    splitStr = split(stringTaxon,"|")   
    for element in splitStr
        if element[1] == desiredClade[1];
            return println("The " * desiredClade * " is " * element[4:end])
        end
    end
end

using Dictionaries

ms = MicrobiomeSample("sample1", Dictionary([:gender, :age], ["female", 180]))

hasclade(t::Taxon)::Bool

taxon_conversion = (k = :kingdom, p = :phylum, c = :class)



function findClade(str, desiredClade) 
    splitStr = split(str, "|")
    for elt in splitStr
        lev_abr = Symbol(first(elt))
        if desiredClade == taxon_conversion[lev_abr] 
            #print(taxon_conversion[lev_abr])  
            name = elt[4:end]
            return(Taxon(name, taxon_conversion[lev_abr]))
        end
    end
end
