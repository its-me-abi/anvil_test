FROM python:3


RUN apt-get -yyy update && apt-get -y install java-1.8.0-amazon-corretto-jdk ghostscript

RUN pip install anvil-app-server
RUN anvil-app-server || true

VOLUME /apps
WORKDIR /apps

RUN mkdir /anvil-data

RUN useradd anvil
RUN chown -R anvil:anvil /anvil-data
USER anvil

ENTRYPOINT ["anvil-app-server","--app",".", "--data-dir", "/anvil-data"]

