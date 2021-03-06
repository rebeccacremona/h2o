FROM python:3.5-stretch
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_SRC=/usr/local/src

RUN mkdir /app
WORKDIR /app

RUN apt-get update && apt-get install -y nano postgresql-client

# nodejs
# write a .yarnrc that will only be found inside the docker guest, and will cause
# node_modules to be written to /node_modules instead of ./node_modules:
RUN echo "--modules-folder /node_modules" > /.yarnrc
COPY package.json /app
COPY yarn.lock /app
# pin node version -- see https://github.com/nodesource/distributions/issues/33
RUN curl -o nodejs.deb https://deb.nodesource.com/node_11.x/pool/main/n/nodejs/nodejs_11.15.0-1nodesource1_amd64.deb \
    && dpkg -i ./nodejs.deb \
    && rm nodejs.deb \
    && npm install -g yarn@1.16.0 \
    && yarn install --frozen-lockfile \
    && rm package.json \
    && rm yarn.lock

RUN mkdir /app/_python
WORKDIR /app/_python

# Custom version of Pandoc, for export
RUN wget https://lilresources.s3.amazonaws.com/h2o/pandoc-889810d -O /usr/bin/pandoc \
    && chmod +x /usr/bin/pandoc

# pip
COPY _python/requirements.txt /app/_python
RUN pip install pip==19.3.1 \
    && pip install -r requirements.txt \
    && rm requirements.txt
