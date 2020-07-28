import json
import sys

import merpy
from tqdm import tqdm

# Notice that this script requires:
#
#   - that the MER's source code is changed, to allow the use of
#     <skos:prefLabel> and <skos:altLabel> properties (used by OCHV)
#   - that a lexicon (whose name is given as the third argument) has been
#     processed by MER
#
# The Dockerfile in this repository takes care of that.

in_filename, lexicon_name, out_filename = sys.argv[1:]

with open(in_filename) as f:
    data = json.load(f)

with open(out_filename, 'w') as f:
    for key, text in tqdm(data.items()):
        annotations = merpy.get_entities(text, lexicon_name)
        json.dump({key: annotations}, f)
        f.write('\n')
        f.flush()
