# Let's find the text of the answers first.
# For that, we need access to the stack exchange API

import csv
import html
import json
import sys

from stackapi import StackAPI

API = StackAPI('stackoverflow')
API._api_key = None

FIELDS = [
    '.backoff',
    '.error_id',
    '.error_message',
    '.error_name',
    '.has_more',
    '.items',
    '.quota_max',
    '.quota_remaining',
    'answer.answer_id',
    'answer.body_markdown',
]

FILTER = API.fetch('filters/create', base='none', include=';'.join(FIELDS))['items'][0]['filter']

MS = StackAPI('medicalsciences')

with open('data/medicalsciences_202004.csv') as f:
    data = list(csv.DictReader(f))

answer_ids = {
    answer['answer_id']
    for answer in data
}

answers = []
answer_ids = list(answer_ids)
while answer_ids:
    print(f'{len(answer_ids)} answers left')

    top = answer_ids[:100]
    answer_ids = answer_ids[100:]

    answers.extend(MS.fetch('answers', ids=top, filter=FILTER)['items'])

def get_body(answer):
    return html.unescape(
        answer['body_markdown'].replace('\r\n', '\n').replace('\r', '\n')
    )

with open(sys.argv[1], 'w') as f:
    json.dump({a['answer_id']: get_body(a) for a in answers}, f)
