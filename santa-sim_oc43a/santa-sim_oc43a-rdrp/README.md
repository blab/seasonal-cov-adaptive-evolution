## Simulate OC43 lineage A Replicase data using SANTA-SIM

Executing the Snakefile will use the SANTA-SIM config files to run SANTA-SIM, format the output into a .fasta file that is compatible with Augur, and use Augur to build a phylogenetic tree and produce an Auspice .json file for visualization.

The Snakefile assumes `santa.jar` is located at `../../../../santa-sim/dist/santa.jar`.

New simulation parameters can be specified by creating a new .xml config file inside the `config/` directory. SANTA-SIM config files should be named `oc43arep_SCHEME.xml` where SCHEME is a unique name for the config file. The config file should save SANTA-SIM output to `data/simulated_rep_oc43a_SCHEME.fasta`. Add `SCHEME` to the list `SCHEME = []` at the top of the Snakefile. 

Existing simulation schemes:
