FROM ubuntu:xenial

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		autoconf \
		ca-certificates \
		dpkg-dev \
		gcc \
		gnupg \
		libncurses5-dev \
		wget \
        curl \
		gosu \
        wget \
        sudo \
        apt-transport-https \
	; \
	rm -rf /var/lib/apt/lists/*; \
# verify that the "gosu" binary works
	gosu nobody true


ADD ./rabbit.list ./rabbit.list
RUN curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | sudo apt-key add - && \
sudo mv ./rabbit.list /etc/apt/sources.list.d/bintray.rabbitmq.list
RUN sudo apt-get update -y &&  sudo apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl
ARG HOST
RUN echo "${HOST}" > /etc/hostname
RUN echo "127.0.0.1    ${HOST}" >> /etc/hosts
RUN sudo apt-get install rabbitmq-server -y --fix-missing

ENV HOSTNAME=$HOST
# Do not use rabbit@hostname because it becones invisible for Pika: https://wiki.archlinux.org/index.php/RabbitMQ
ENV RABBITMQ_NODENAME=rabbit@$HOSTNAME
ENV RABBITMQ_USE_LONGNAME=false
# ENV RABBITMQ_NODE_IP_ADDRESS=
ENV RABBITMQ_LOGS=-
ENV RABBITMQ_CONFIG_FILE=/etc/rabbitmq/rabbitmq
ENV RABBITMQ_CONF_ENV_FILE=/etc/rabbitmq/rabbitmq-env.conf
ENV RABBITMQ_DATA_DIR=/var/lib/rabbitmq
# Are they same?????????????????????????
ENV RABBITMQ_HOME=${RABBITMQ_DATA_DIR} 

ADD ./conf-initial/*.conf /etc/rabbitmq/
ADD ./docker-entrypoint.sh .
ADD ./init-users.sh .

VOLUME ["${RABBITMQ_DATA_DIR}"]

# Map config folder
VOLUME ["/etc/rabbitmq"]

ENV LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8

# Fixing issue with zombies in rabbit/erlang:
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64
RUN chmod +x /usr/local/bin/dumb-init

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]

EXPOSE 4369 5671 5672 15671 15672 25672

CMD ["bash", "-c", "docker-entrypoint.sh && exec rabbitmq-server"]
