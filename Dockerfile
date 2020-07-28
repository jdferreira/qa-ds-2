FROM python:3

RUN apt update -y && apt install -y jq gawk

WORKDIR /app

COPY requirements.txt /app
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ /app/src
COPY bioportal_apikey /app

CMD [ "bash", "src/pipeline.sh" ]
