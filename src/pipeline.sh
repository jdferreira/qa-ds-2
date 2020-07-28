# Let's start by grabing the medical sciences dataset
COMMIT='898378cf9ded103f9b18ce2584723070f50d83c8'
URL="https://raw.githubusercontent.com/lasigeBioTM/BiQA/$COMMIT/april2020/medicalsciences_202004.csv"
curl "$URL" > data/medicalsciences_202004.csv

# Now get the actual answers, using the stack excehange API
python src/get_answer_bodies.py data/answers.json

if false; then
    # By using Bioportal's API, I can see that the ontologies that better annotate
    # the answers are probably NCIT, OCHV, SNOMEDCT and MESH.

    # To do that, let's grab a few lines of answers, as sending all of them
    # would not be nice to BioPortal's web service. We'll restrict our request
    # to the first `N` lines of text
    N=100
    jq '.[]' data/answers.json | head -n ${N} > data/${N}_lines_ofanswers.txt

    BIOPORTAL_APIKEY="$(cat bioportal_apikey)"
    URL='http://data.bioontology.org/recommender'
    curl $URL \
        --header 'Authorization: apikey token='"$BIOPORTAL_APIKEY" \
        --data-urlencode input@data/${N}_lines_ofanswers.txt \
        -d 'display_context=false' \
        -d 'display_links=false' \
        > data/recommendations.json

    # Notice that this block of code is inside a `if false` block, because this
    # is not strictly needed and I have already run it and determined that the
    # best ontologies are NCIT, SNOMEDCT, OCHV, RCD and MESH. SNOMED and RCD are
    # not easily accessible and as such they are ignored for now.
fi

# Finally, annotate the answers with these ontologies
python src/annotate.py data/answers.json data/annotations.json
