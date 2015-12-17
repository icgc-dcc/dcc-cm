FROM logstash:latest

RUN apt-get update && apt-get install -y netcat

COPY entrypoint.sh /tmp/entrypoint.sh
RUN chmod +x /tmp/entrypoint.sh

COPY config/logstash.conf /etc/logstash/conf.d/logstash.conf

CMD ["/tmp/entrypoint.sh"]