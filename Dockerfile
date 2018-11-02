ARG VERSION=latest
FROM ubuntu:${VERSION}

RUN apt-get update && apt-get -y install openssh-server sudo
ADD run.sh /run.sh
RUN chmod +x /run.sh

RUN mkdir -p /var/run/sshd && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir -p /root/.ssh

EXPOSE 22
CMD ["/run.sh"]
