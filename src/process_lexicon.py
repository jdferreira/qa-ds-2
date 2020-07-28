import merpy
import sys

whole_lexicons_parts = []

for lexicon in sys.argv[1].split(','):
    lexicon_name, lexicon_type = lexicon.split('.')
    merpy.process_lexicon(lexicon_name, lexicon_type)

    whole_lexicons_parts.append(lexicon_name)

merpy.merge_processed_lexicons(whole_lexicons_parts, sys.argv[2])
