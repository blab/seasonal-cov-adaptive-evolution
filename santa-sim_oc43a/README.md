## Simulate OC43 lineage A sequence data using SANTA-SIM

Executing the Snakefile will use the SANTA-SIM config files to run SANTA-SIM, format the output into a .fasta file that is compatible with Augur, and use Augur to build a phylogenetic tree and produce an Auspice .json file for visualization.

The Snakefile assumes `santa.jar` is located at `../../../../santa-sim/dist/santa.jar`.

New simulation parameters can be specified by creating a new .xml config file inside the `config/` directory. SANTA-SIM config files should be named `oc43arep_SCHEME.xml` where SCHEME is a unique name for the config file. The config file should save SANTA-SIM output to `data/simulated_{gene}_oc43a_SCHEME.fasta`. Add `SCHEME` to the list `SCHEME = []` at the top of the Snakefile. 

Existing simulation schemes:
| scheme | pos_selection | recombination | mutation_rate | exp_dep_penalty | rep_parameters  | purifying_parameters                                                  |
|--------|---------------|---------------|---------------|-----------------|-----------------|-----------------------------------------------------------------------|
| s1     | None          | None          | 1E-4          | 0               | clonal          | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.8, 0.7                   |
| s2     | Low           | None          | 1E-4          | 0.03            | clonal          | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.97, 0.1, fluctuate 0.001 |
| s3     | Moderate      | None          | 1E-4          | 0.05            | clonal          | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.95, 0.1, fluctuate 0.001 |
| s4     | High          | None          | 1E-4          | 0.1             | clonal          | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.9, 0.1, fluctuate 0.001  |
| s5     | None          | Low           | 1E-4          | 0               | 0.001, 0.000001 | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.8, 0.7                   |
| s6     | Low           | Low           | 1E-4          | 0.03            | 0.001, 0.000001 | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.97, 0.1, fluctuate 0.001 |
| s7     | Moderate      | Low           | 1E-4          | 0.05            | 0.001, 0.000001 | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.95, 0.1, fluctuate 0.001 |
| s8     | High          | Low           | 1E-4          | 0.1             | 0.001, 0.000001 | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.9, 0.1, fluctuate 0.001  |
| s9     | None          | Moderate      | 1E-4          | 0               | 0.01, 0.00001   | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.8, 0.7                   |
| s10    | Low           | Moderate      | 1E-4          | 0.03            | 0.01, 0.00001   | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.97, 0.1, fluctuate 0.001 |
| s11    | Moderate      | Moderate      | 1E-4          | 0.05            | 0.01, 0.00001   | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.95, 0.1, fluctuate 0.001 |
| s12    | High          | Moderate      | 1E-4          | 0.1             | 0.01, 0.00001   | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.9, 0.1, fluctuate 0.001  |
| s13    | None          | High          | 1E-4          | 0               | 0.1, 0.0001     | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.8, 0.7                   |
| s14    | Low           | High          | 1E-4          | 0.03            | 0.1, 0.0001     | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.97, 0.1, fluctuate 0.001 |
| s15    | Moderate      | High          | 1E-4          | 0.05            | 0.1, 0.0001     | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.95, 0.1, fluctuate 0.001 |
| s16    | High          | High          | 1E-4          | 0.1             | 0.1, 0.0001     | rdrp/spike-nonepitope:0.8, 0.7 s1-epitope: 0.9, 0.1, fluctuate 0.001  |
