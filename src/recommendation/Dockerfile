FROM python:3.12-slim-bookworm

WORKDIR /src/recommendation/

COPY . .
RUN pip install --upgrade pip && pip install --prefix="/usr/local/" -r requirements.txt

ENV RECOMMENDATION_PORT 1010

ENTRYPOINT python recommendation_server.py