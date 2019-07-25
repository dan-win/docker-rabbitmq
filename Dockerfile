FROM ubuntu:xenial

# RUN sudo apt-get update && \
# sudo apt-get upgrade && \
# cd ~ && \
# wget http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_20.1-1~ubuntu~xenial_amd64.deb && \
# sudo dpkg -i esl-erlang_20.1-1\~ubuntu\~xenial_amd64.deb && \
# echo "deb https://dl.bintray.com/rabbitmq/debian xenial main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list && \
# wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add - && \
# sudo apt-get update && \
# sudo apt-get install rabbitmq-server && \
# sudo systemctl start rabbitmq-server.service && \
# sudo systemctl enable rabbitmq-server.service

# RUN sudo rabbitmq-plugins enable rabbitmq_management && \
# sudo chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/

# RUN sudo rabbitmqctl add_user admin password && \
# sudo rabbitmqctl set_user_tags admin administrator && \
# sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*" && \
# sudo rabbitmqctl add_user mqadmin mqadminpassword && \
# sudo rabbitmqctl set_user_tags mqadmin administrator && \
# sudo rabbitmqctl set_permissions -p / mqadmin ".*" ".*" ".*"

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

# RUN deb https://dl.bintray.com/rabbitmq/ubuntu xenial erlang-22.x 

# RUN sudo apt-get update -y && sudo apt-get install -y erlang-base \
#                         erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
#                         erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
#                         erlang-runtime-tools erlang-snmp erlang-ssl \
#                         erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

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



# RUN curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.deb.sh | sudo bash && sudo apt-get install rabbitmq-server

# RUN wget -O - "https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey" | sudo apt-key add - && \
# curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.deb.sh | sudo bash 
# && \

# RUN sudo rabbitmq-plugins enable rabbitmq_management 
# && \
# sudo chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/


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
# ENV RABBITMQ_LOGS=/var/log/rabbitmq/rabbit-erlang.log
# ENV RABBITMQ_ENABLED_PLUGINS_FILE=/etc/rabbitmq/enabled_plugins

# ENV RABBITMQ_LOGS=/var/log/rabbitmq/rabbit.log

# RUN mkdir -p /tmp/plugins_expand && chmod -R 777 /tmp/plugins_expand



ADD ./conf-initial/*.conf /etc/rabbitmq/
ADD ./docker-entrypoint.sh .
ADD ./init-users.sh .

VOLUME ["${RABBITMQ_DATA_DIR}"]

# Map config folder
VOLUME ["/etc/rabbitmq"]


# RUN sudo service rabbitmq-server stop && \
# sudo service rabbitmq-server start 

# RUN sudo rabbitmq-plugins enable rabbitmq_management && \
# sudo chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/

# RUN sudo rabbitmqctl add_user admin password && \
# sudo rabbitmqctl set_user_tags admin administrator && \
# sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*" && \
# sudo rabbitmqctl add_user mqadmin mqadminpassword && \
# sudo rabbitmqctl set_user_tags mqadmin administrator && \
# sudo rabbitmqctl set_permissions -p / mqadmin ".*" ".*" ".*"

# RUN sudo rabbitmqctl  delete_user guest || true && \
# sudo rabbitmqctl  add_vhost tvz && \
# sudo rabbitmqctl  add_user amad minnes0ta && \
# sudo rabbitmqctl  set_user_tags amad administrator && \
# sudo rabbitmqctl  add_user tvz_api 10nd0n && \
# sudo rabbitmqctl  set_permissions -p tvz tvz_api ".*" ".*" ".*" && \
# sudo rabbitmqctl  add_user pyaccessor 1issab0n && \
# sudo rabbitmqctl  set_permissions -p tvz pyaccessor ".*" ".*" ".*"

# USER 999:999

ENV LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 4369 5671 5672 15671 15672 25672
# USER rabbitmq
CMD ["rabbitmq-server"]