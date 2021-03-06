BIOPORTAL_APIKEY="$(cat bioportal_apikey)"

# We need to convince MER to do what we want with the ontologies. In particular,
# we must create the lexicons and patch the MER scripts to recognize the label
# properties that our ontologies use

# Find the directory where the ontologies must be included and cd into it
MER="$(dirname $(python -c 'print(__import__("merpy").__file__)'))/MER"

# Download the necessary ontologies into this directory
for ont in ochv ncit; do
    # Only download if the ontology does not already exist in the data directory
    if [ ! -f data/"$ont".owl ]; then
        curl 'http://data.bioontology.org/ontologies/OCHV/submissions/2/download?apikey='"$BIOPORTAL_APIKEY" \
            -o data/"$ont".owl
    fi

    # Copy the ontology in the data directory into MER's data directory
    cp data/"$ont".owl "$MER"/data/"$ont".owl
done

# MER uses a hard coded set of properties to get labels and synonyms from the
# ontologies. Some ontologies use different properties, and as such we must
# patch MER to use them as well. In particular, this includes <skos:prefLabel>
# and <skos:altLabel>

# Technical note: The `REPALCE_THIS` text searches for the placeholder text we
# wish to find on the text, which is one of the properties used for labels,
# optionally followed by the text we wish to add there. We do this to prevent
# adding the properties multiple times.

REPLACE_THIS="-e 'oboInOwl:hasRelatedSynonym' (-e 'skos:prefLabel' -e 'skos:altLabel' )?"
WITH_THIS="-e 'oboInOwl:hasRelatedSynonym' -e 'skos:prefLabel' -e 'skos:altLabel' "
sed "s/$REPLACE_THIS/$WITH_THIS/" -i "$MER/produce_data_files.sh"

# Let MER process these lexicons, including merging them into a single one.
python <<EOF
import merpy
merpy.process_lexicon('ochv', 'owl')
merpy.process_lexicon('ncit', 'owl')
merpy.merge_processed_lexicons(['ochv', 'ncit'], 'ochvnncit')
EOF
