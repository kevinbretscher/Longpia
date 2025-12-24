mkdir -p databases

echo "Downloading pre-sketched SKANI GTDB database..."

wget http://faust.compbio.cs.cmu.edu/skani-files/skani_gtdb_r226-v0.3.tar.gz -O databases/skani_gtdb_r226-v0.3.tar.gz
mkdir -p databases/skani
tar -xzvf databases/skani_gtdb_r226-v0.3.tar.gz -C databases/skani
rm databases/skani_gtdb_r226-v0.3.tar.gz

