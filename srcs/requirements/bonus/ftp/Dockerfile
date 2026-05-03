FROM debian:bookworm

RUN apt-get update && apt-get install -y vsftpd \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf


# EXPOSE 21 21000-21010

# CMD ["/entrypoint.sh"]

CMD ["vsftpd", "/etc/vsftpd.conf"]

