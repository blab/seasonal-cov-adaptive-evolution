import argparse
from datetime import timedelta, datetime
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord


def format_alignment(path_to_alignment):
    date_range = [1986, 2019]
    gen_to_year = {}

    split_path = path_to_alignment.split('_')
    new_file_path = split_path[0]+'_'+split_path[1]+'spike_'+split_path[2]

    with open(path_to_alignment, "r") as handle:
        #find sampled generations
        generations = []
        for record in SeqIO.parse(handle, "fasta"):
            generation = record.description.split('|')[1]
            generations.append(int(generation))

        #only need unique generation entries. Add 0 for root
        generations = [0]+list(set(generations))

        start_gen = 0
        end_gen = max(generations)

        #find number of sampled generations
        num_gens = len(generations)

        gen_step = end_gen/(num_gens-1)
        year_step = (date_range[1]-date_range[0])/(num_gens-1)

        #map generation to year
        for i in range(num_gens):
            gen = 0+gen_step*i
            year = date_range[0]+year_step*i
            gen_to_year[gen] = year

    with open(path_to_alignment, "r") as handle:
        new_simulated_records = []
        #convert generation number to year
        for record in SeqIO.parse(handle, "fasta"):
            generation = int(record.description.split('|')[1])

            assigned_date = gen_to_year[generation]
            assigned_year = int(assigned_date)
            d = timedelta(days=(assigned_date - assigned_year)*365)
            day_one = datetime(assigned_year,1,1)
            date = d + day_one

            assigned_year_description = record.description.split('|')
            assigned_year_description[0] = assigned_year_description[0].replace('_','/')
            assigned_year_description[1] = date.strftime("%Y-%m-%d")
            assigned_year_description.pop(2)
            assigned_year_description = '|'.join(assigned_year_description)
            new_record = SeqRecord(record.seq, id= assigned_year_description,
                                   name= assigned_year_description, description= assigned_year_description)
            new_simulated_records.append(new_record)

        SeqIO.write(new_simulated_records, new_file_path, 'fasta')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description = "Formats simulated spike sequences for Augur")
    parser.add_argument('--alignment', help= "alignment output of SANTA-SIM")
    args = parser.parse_args()

    format_alignment(args.alignment)
