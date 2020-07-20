## Simulate OC43 lineage A Spike data using SANTA-SIM

Executing the Snakefile will use the SANTA-SIM config files to run SANTA-SIM, format the output into a .fasta file that is compatible with Augur, and use Augur to build a phylogenetic tree and produce an Auspice .json file for visualization.

The Snakefile assumes `santa.jar` is located at `../../../santa-sim/dist/santa.jar`.

New simulation parameters can be specified by creating a new .xml config file inside the `config/` directory. SANTA-SIM config files should be named `oc43aspike_SCHEME.xml` where SCHEME is a unique name for the config file. The config file should save SANTA-SIM output to `data/simulated_oc43a_SCHEME.fasta`. Add `SCHEME` to the list `SCHEME = []` at the top of the Snakefile. 

Existing simulation schemes:

For all: 
- Signal peptide and S2 are under purifying selection
- RBD of S1 is under strong purifying selection. The RBD was determined empirically (Hulswit et al, 2019)
- Non-epitope and non-RBD sites in S1 are under weak purifying selection, with "fluctuate" that allows the preferred amino acid to change slowly over time
- Epitope sites in S1 are also under weak purifying selection, with "fluctuate" that allows the preferred amino acid to change faster. The default number of epitope sites is 95, which is based on the percentage of HA sites that are epitopes in influenza H3N2
- Additionally, epitope sites are under exposure dependent (positive) selection

| scheme | pos_selection | recombination | mutation_rate | exp_dep_penalty | rep_parameters |
|--------|---------------|---------------|---------------|-----------------|----------------|
| s1     | Yes           | No            | 1E-4          | 0.01            | NA             |
| s2     | Yes           | Yes           | 1E-4          | 0.01            | 0.01, 0.001    |
| s3     | No            | No            | 1E-4          | NA              | NA             |
| s4     | No            | Yes           | 1E-4          | NA              | 0.01, 0.001    |
| s5     | Yes           | No            | 1E-4          | 0.05            | NA             |
| s6     | Yes           | No            | 1E-4          | 0.005           | NA             |
| s7     | Yes           | No            | 1E-4          | 0.1             | NA             |
| s8     | Yes           | Yes           | 1E-4          | 0.01            | 0.001, 0.001   |
| s9     | Yes           | Yes           | 1E-4          | 0.01            | 0.001, 0.0001  |
| s10    | Yes           | Yes           | 1E-4          | 0.01            | 0.1, 0.01      |
| s11    | Yes           | Yes           | 5E-5          | 0.01            | 0.01, 0.001    |
| s12    | Yes           | Yes           | 1E-5          | 0.01            | 0.01, 0.001    |
| s13    | Yes           | Yes           | 2E-4          | 0.01            | 0.01, 0.001    |
| s14    | Yes           | Yes           | 2E-4          | 0.05            | 0.01, 0.001    |
| s15    | Yes           | Yes           | 2E-4          | 0.05            | 0.1, 0.001     |