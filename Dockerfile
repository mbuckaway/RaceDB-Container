FROM python:3

RUN apt-get update \
  && apt-get install -y\
    git \
    cron \
    vim.tiny

ENV sqlite3_database_fname=/racedb-data/RaceDB.sqlite3
ENV RACEDBLOGFILE=/racedb-data/RaceDB-log.txt

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
    chmod 755 /RaceDB/manage.py && \
    cd /RaceDB && \
    /RaceDB/manage.py collectstatic --no-input

ENV PYTHONPATH=/RaceDB
COPY docker-entrypoint-init.d/* /docker-entrypoint-init.d/
COPY build-files/entrypoint.sh /usr/sbin/entrypoint.sh

EXPOSE 8000

CMD ["/usr/sbin/entrypoint.sh"]
