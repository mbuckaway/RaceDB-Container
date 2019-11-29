FROM python:3

RUN apt-get update \
  && apt-get install -y\
    git \
    cron \
    vim.tiny

RUN groupadd racedb && \
    mkdir -p /docker-entrypoint-init.d/ && \
    cd / && \
    git clone https://github.com/mbuckaway/RaceDB.git && \
    cd /RaceDB && \
    rm -rf .git && \
    python3 -m pip install -r requirements.txt && \
    python3 -m pip install PyMySQL mysqlclient psycopg2 markdown && \
    mkdir -p /RaceDB/core/static/docs && \
    cd /RaceDB/helptxt && \
    python3 compile.py && \
    chmod 755 /RaceDB/manage.py

COPY docker-entrypoint-init.d/* /docker-entrypoint-init.d/
COPY build/entrypoint.sh /usr/sbin/entrypoint.sh

CMD "/usr/sbin/entrypoint.sh"
