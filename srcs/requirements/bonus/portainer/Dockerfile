FROM debian:bookworm

RUN apt-get update && apt-get install -y curl\
    && curl -L https://github.com/portainer/portainer/releases/download/2.20.3/portainer-2.20.3-linux-amd64.tar.gz -o portainer.tar.gz\
    && tar -xzf portainer.tar.gz\
    && mv portainer /opt/portainer\
    && rm portainer.tar.gz\
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]