FROM python:3

RUN apt update -y && apt install -y jq gawk

WORKDIR /app
COPY . /app

RUN pip install --no-cache-dir -r requirements.txt
RUN bash src/prepare_mer.sh

CMD [ "bash", "src/pipeline.sh" ]
