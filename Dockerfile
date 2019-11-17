FROM python:3

RUN apt-get update \
  && apt-get install -y\
    git \
    cron 

RUN groupadd racedb && \
    useradd -g racedb -m racedb && \
    cd /home/racedb && \
    git clone https://github.com/mbuckaway/RaceDB.git && \
    cd /home/racedb/RaceDB && \
    python3 -m pip install -r requirements.txt &&\
    mkdir -p /entrypoint-init.d/
COPY entrypoint-init.d/* /entrypoint-init.d/
COPY build/entrypoint.sh /usr/sbin/entrypoint.sh

ENTRYPOINT [ "/usr/sbin/entrypoint.sh" ]
