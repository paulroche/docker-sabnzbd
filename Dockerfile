FROM debian:8
MAINTAINER Paul Roche 
# cloned from https://github.com/domibarton/docker-sickbeard

#
# Add startup script.
#

COPY assets/scripts/sabnzbd.sh /opt/sabnzbd.sh

#
# Install Sabnzbd and all required dependencies.
#

RUN sed -i "s/jessie main/jessie main contrib non-free/" /etc/apt/sources.list

RUN apt-get -qq update \
    && apt-get install -yf curl            \
                           ca-certificates \
                           python-cheetah  \
                           python-openssl  \
                           python-yenc     \
                           unrar           \
                           unzip           \
                           par2            \

    && apt-get -y autoremove               \
    && apt-get -y clean                    \
    && rm -rf /var/lib/apt/lists/*

# install SAB
RUN mkdir /sabnzbd
RUN curl -SL https://github.com/sabnzbd/sabnzbd/releases/download/1.0.0/SABnzbd-1.0.0-src.tar.gz | tar -xzC /sabnzbd --strip-components=1

#
# Start SAB.
#

ENTRYPOINT ["/opt/sabnzbd.sh"]
