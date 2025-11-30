
mkdir -p databases

echo "Downloading CheckM and CheckM2 databases..."
wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz -O databases/checkm_data_2015_01_16.tar.gz
mkdir -p databases/checkm
tar -xzvf databases/checkm_data_2015_01_16.tar.gz -C databases/checkm

wget https://zenodo.org/records/14897628/files/checkm2_database.tar.gz?download=1 -O databases/checkm2_database.tar.gz
mkdir -p databases/checkm2
tar -xzvf databases/checkm2_database.tar.gz -C databases/checkm2

wget https://zenodo.org/record/10158040/files/201123_plassembler_v1.5.0_databases.tar.gz -O databases/plassembler_databases.tar.gz
mkdir -p databases/plassembler
tar -xzvf databases/plassembler_databases.tar.gz -C databases/plassembler