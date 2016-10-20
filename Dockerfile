FROM resin/raspberrypi3-debian
MAINTAINER geofrey Ernest

# Let's start with some basic stuff.
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables\
	openssh-server\
    &&apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Docker from hypriot repos
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 37BBEE3F7AD95B3F && \
    echo "deb https://packagecloud.io/Hypriot/Schatzkiste/debian/ wheezy main" > /etc/apt/sources.list.d/hypriot.list && \
    apt-get update && \
    apt-get install -y docker-hypriot docker-compose\
    &&apt-get clean && rm -rf /var/lib/apt/lists/*

# here we set up the config for openSSH.
RUN mkdir /var/run/sshd \
    && echo 'root:resin' | chpasswd \
    && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

VOLUME ["/var/lib/docker" ]

COPY ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

COPY ./services /services

# Enable systemd init system in the container, so it never closes
ENV INITSYSTEM on
WORKDIR /voxbox

COPY ./start /start
RUN chmod +x /start

CMD ["/start"]
