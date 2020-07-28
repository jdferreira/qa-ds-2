BIOPORTAL_APIKEY="$(cat bioportal_apikey)"
MER="$(dirname $(python -c 'print(__import__("merpy").__file__)'))/MER"

patch_mer() {
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
}

prepare_lexicons() {
    # Download the necessary ontologies into this directory
    for ont in ochv ncit; do
        # Only download if the ontology does not already exist in the data directory
        if [ ! -f data/"$ont".owl ]; then
            curl "http://data.bioontology.org/ontologies/${ont^^}/submissions/2/download?apikey=$BIOPORTAL_APIKEY" \
                -o data/"$ont".owl
        fi

        # Copy the ontology in the data directory into MER's data directory
        cp data/"$ont".owl "$MER"/data/"$ont".owl
    done

    # Let MER process these lexicons, including merging them into a single one.
    python src/process_lexicons.py 'ochv.owl,ncit.owl' 'whole_lexicon'
}

get_answers_dataset() {
    COMMIT='898378cf9ded103f9b18ce2584723070f50d83c8'
    URL="https://raw.githubusercontent.com/lasigeBioTM/BiQA/$COMMIT/april2020/medicalsciences_202004.csv"
    curl "$URL" > data/medicalsciences_202004.csv

    python src/get_answer_bodies.py data/answers.json
}

annotate_answers() {
    # Annotate the answers with these ontologies
    python src/annotate.py data/answers.json 'whole_lexicon' data/annotations.json
}

patch_mer

prepare_lexicons

if [ ! -f data/answers.json ]; then
    get_answers_dataset
fi

annotate_answers
