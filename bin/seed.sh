#!/bin/bash
# 
# Seeds the RDF store with pension yearbook data
# 

set -e

wget -q https://data.cssz.cz/dump/duchodci-v-cr-krajich-okresech.trig -P data
wget -q https://data.cssz.cz/dump/rocenka-vocabulary.trig -P data
wget -q https://data.cssz.cz/dump/duchodci-v-cr-krajich-okresech-metadata.trig -P data
wget -q https://data.cssz.cz/dump/pomocne-ciselniky.trig -P data
wget -q http://purl.org/linked-data/cube# -O data/cube.ttl

# Remove lock if there's one.
rm $STARDOG_HOME/system.lock 2>/dev/null || true

cd bin

./stardog-admin server start

# Wait a bit for Stardog to start.
sleep 1

# Create SPARQLab database
./stardog-admin db create -n sparqlab --config $STARDOG_HOME/stardog.properties

# Load data
./stardog data add sparqlab ../data/duchodci-v-cr-krajich-okresech.trig \
                            ../data/rocenka-vocabulary.trig \
                            ../data/duchodci-v-cr-krajich-okresech-metadata.trig \
                            ../data/pomocne-ciselniky.trig
./stardog data add sparqlab -g http://purl.org/linked-data/cube ../data/cube.ttl

# Transform data
./stardog query sparqlab ../setup/sparql/fix_https_in_pension_kinds_1.ru
./stardog query sparqlab ../setup/sparql/fix_https_in_pension_kinds_2.ru
./stardog query sparqlab ../setup/sparql/rewrite_genders.ru

./stardog-admin server stop

# Cleanup
rm -r ../data
