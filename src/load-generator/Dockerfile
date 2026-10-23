FROM python:3.12-slim-bookworm 
WORKDIR /src/load-generator

COPY ./src/load-generator .
RUN pip install --upgrade pip && pip install --prefix="/usr/local/" -r requirements.txt
ENV LOCUST_PLAYWRIGHT=1
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/pw-browsers
RUN playwright install --with-deps chromium

ENTRYPOINT locust --skip-log-setup