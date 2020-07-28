import json
import sys

import merpy
from tqdm import tqdm

# Notice that this script requires:
#
#   - that the MER's source code is changed, to allow the use of
#     <skos:prefLabel> and <skos:altLabel> properties (used by OCHV)
#   - that the OCHV and NCIT ontologies have been loaded as lexicons into MER
#     with the names 'ochv' and 'ncit'
#   - that the 'ochv' and 'ncit' lexicons have been merged into the 'ochv_ncit'
#     lexicon.
#
# The Dockerfile in this repository takes care of that.

with open(sys.argv[1]) as f:
    data = json.load(f)

annotations = {}
for key, text in tqdm(data.items()):
    annotations[key] = merpy.get_entities(text, sys.argv[2])

with open(sys.argv[3], 'w') as f:
    json.dump(annotations, f)
