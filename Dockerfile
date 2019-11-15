FROM python:3

RUN apt-get update \
  && apt-get install -y\
    git \
    cron 

#COPY requirements.txt ./
#RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir -p /entrypoint-init.d/
COPY entrypoint-init.d/* /entrypoint-init.d/
COPY build/entrypoint.sh /usr/sbin/entrypoint.sh

ENTRYPOINT [ "/usr/sbin/entrypoint.sh" ]
