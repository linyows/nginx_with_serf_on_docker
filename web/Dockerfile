FROM ubuntu

RUN apt-get -y update
RUN apt-get install -y supervisor unzip nginx

# Install serf
ADD https://dl.bintray.com/mitchellh/serf/0.6.1_linux_amd64.zip serf.zip
RUN unzip serf.zip
RUN mv serf /usr/bin/
RUN rm *.zip

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get remove --purge -y unzip
RUN apt-get autoremove -y

# Copy configuration
ADD ./config/nginx.conf /etc/nginx/nginx.conf
ADD ./config/web.conf /etc/nginx/sites-enabled/default
ADD ./config/supervisord.conf /etc/supervisor/conf.d/supervisord-nginx-serf.conf

# Copy scripts
ADD ./scripts/serf-member-join.sh /serf-member-join.sh
ADD ./scripts/serf-member-leave.sh /serf-member-leave.sh
ADD ./scripts/serf-join.sh /serf-join.sh
ADD ./scripts/start-serf.sh /start-serf.sh
RUN chmod 755 /*.sh

EXPOSE 80
CMD ["supervisord", "-n"]
