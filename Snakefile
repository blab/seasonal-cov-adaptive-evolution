# VIRUS = ["oc43", "hku1", "229e", "nl63"]
VIRUS = ["oc43", "oc43", "oc43", "hku1", "hku1", "hku1", "229e", "229e", "nl63", "nl63"]
GENE = ["spike", "he", "full", "spike", "he", "full", "spike", "full", "spike", "full"]

# def _get_gene_by_wildcards(wildcards):
#     genes = {"oc43":["spike", "he"], "hku1":["spike", "he"], "229e":["spike"], "nl63":["spike"]}
#     return genes[wildcards.virus]


rule all:
    input:
        auspice_json = expand("auspice/seasonal_corona_{virus}_{gene}.json", zip, virus=VIRUS, gene= GENE)

rule files:
    params:
        # include = "config/include.txt",
        # dropped_strains = "config/dropped_strains.txt",
        reference = "config/{virus}_{gene}_reference.gb",
        auspice_config = "config/auspice_config.json",
        lat_longs = "config/lat_longs.tsv",
        colors = "config/colors.tsv"
        # description = "config/description.md"

files = rules.files.params

rule download:
    message: "Downloading sequences from fauna"
    output:
        sequences = "data/{virus}_{gene}.fasta"
    params:
        fasta_fields = "accession strain virus collection_date country sequence_locus subtype type"
    shell:
        """
        python3 ../fauna/vdb/download.py \
            --database vdb \
            --virus seasonal_corona \
            --fasta_fields {params.fasta_fields} \
            --select sequence_locus:{wildcards.gene} subtype:{wildcards.virus}\
            --path $(dirname {output.sequences}) \
            --fstem $(basename {output.sequences} .fasta)
        """

rule parse:
    message: "Parsing fasta into sequences and metadata"
    input:
        sequences = rules.download.output.sequences
    output:
        sequences = "results/sequences_{virus}_{gene}.fasta",
        metadata = "results/metadata_{virus}_{gene}.tsv"
    params:
        fasta_fields = "accession strain virus date country source sequence_locus subtype type",
    shell:
        """
        augur parse \
            --sequences {input.sequences} \
            --output-sequences {output.sequences} \
            --output-metadata {output.metadata} \
            --fields {params.fasta_fields} \
        """

# def _get_min_length_by_wildcards(wildcards):
#     if wildcards.gene == "spike":
#         min_length = 1000
#     elif wildcards.gene == "he":
#         min_length = 1000
#     elif wildcards.gene == "genome":
#         min_length = 20000
#     return(min_length)

rule filter:
    message:
        """
        Filtering to
          - {params.sequences_per_group} sequence(s) per {params.group_by!s}
          - minimum genome length of {params.min_length}
        """
    input:
        sequences = rules.parse.output.sequences,
        metadata = rules.parse.output.metadata,
    output:
        sequences = "results/filtered_{virus}_{gene}.fasta"
    params:
        group_by = "country",
        sequences_per_group = 5000,
        min_length = 1000
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --output {output.sequences} \
            --group-by {params.group_by} \
            --sequences-per-group {params.sequences_per_group} \
            --min-length {params.min_length}
        """

rule align:
    message:
        """
        Aligning sequences to {input.reference}
          - filling gaps with N
        """
    input:
        sequences = rules.filter.output.sequences,
        reference = files.reference
    output:
        alignment = "results/aligned_{virus}_{gene}.fasta"
    shell:
        """
        augur align \
            --sequences {input.sequences} \
            --reference-sequence {input.reference} \
            --output {output.alignment} \
            --remove-reference \
            --fill-gaps
        """

rule tree:
    message: "Building tree"
    input:
        alignment = rules.align.output.alignment
    output:
        tree = "results/tree_raw_{virus}_{gene}.nwk"
    shell:
        """
        augur tree \
            --alignment {input.alignment} \
            --output {output.tree}
        """

rule refine:
    message:
        """
        Refining tree
        """
    input:
        tree = rules.tree.output.tree,
        alignment = rules.align.output,
        metadata = rules.parse.output.metadata
    output:
        tree = "results/tree_{virus}_{gene}.nwk",
        node_data = "results/branch_lengths_{virus}_{gene}.json"
    params:
        coalescent = "opt",
        date_inference = "marginal"
    shell:
        """
        augur refine \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --metadata {input.metadata} \
            --output-tree {output.tree} \
            --output-node-data {output.node_data} \
            --timetree \
            --coalescent {params.coalescent} \
            --date-confidence \
            --date-inference {params.date_inference} \
            --clock-filter-iqd 4
        """

rule ancestral:
    message: "Reconstructing ancestral sequences and mutations"
    input:
        tree = rules.refine.output.tree,
        alignment = rules.align.output
    output:
        node_data = "results/nt_muts_{virus}_{gene}.json"
    params:
        inference = "joint"
    shell:
        """
        augur ancestral \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --output {output.node_data} \
            --inference {params.inference}
        """

rule translate:
    message: "Translating amino acid sequences"
    input:
        tree = rules.refine.output.tree,
        node_data = rules.ancestral.output.node_data,
        reference = files.reference
    output:
        node_data = "results/aa_muts_{virus}_{gene}.json"
    shell:
        """
        augur translate \
            --tree {input.tree} \
            --ancestral-sequences {input.node_data} \
            --reference-sequence {input.reference} \
            --output-node-data {output.node_data}
        """
#
# rule traits:
#     message: "Inferring ancestral traits for country"
#     input:
#         tree = rules.refine.output.tree,
#         metadata = rules.parse.output.metadata
#     output:
#         node_data = "results/traits_{virus}_{gene}.json",
#     shell:
#         """
#         augur traits \
#             --tree {input.tree} \
#             --metadata {input.metadata} \
#             --output-node-data {output.node_data} \
#             --columns "country" \
#             --confidence
#         """

rule export:
    message: "Exporting data files for for auspice"
    input:
        tree = rules.refine.output.tree,
        metadata = rules.parse.output.metadata,
        branch_lengths = rules.refine.output.node_data,
        # traits = rules.traits.output.node_data,
        nt_muts = rules.ancestral.output.node_data,
        aa_muts = rules.translate.output.node_data,
        lat_longs = files.lat_longs,
        auspice_config = files.auspice_config,
        colors = files.colors
        # description = files.description
    output:
        auspice_json = "auspice/seasonal_corona_{virus}_{gene}.json"
        # auspice_json = rules.all.input.auspice_json
    shell:
        """
        augur export v2 \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --node-data {input.branch_lengths} {input.nt_muts} {input.aa_muts} \
            --auspice-config {input.auspice_config} \
            --lat-longs {input.lat_longs} \
            --colors {input.colors} \
            --output {output.auspice_json}
        """

rule clean:
    message: "Removing directories: {params}"
    params:
        "results ",
        "auspice"
    shell:
        "rm -rfv {params}"
