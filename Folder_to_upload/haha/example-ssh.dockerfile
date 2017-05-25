FROM ubuntu:16.04
MAINTAINER Yang Liu <yaliu@adobe.com>

ARG username
ARG groupname
ARG uid
ARG gid

RUN addgroup -gid $gid $groupname
RUN useradd -ms /bin/bash -u $uid -g $gid $username

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN chown -R $username:$groupname /etc/ssh

RUN mkdir /home/$username/.ssh
RUN echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDsI/h8OMc1RAnNAop/U6G96B6VeiysoGhQt7knzAlmsrRT1qRqv2BuG3Byj11/6lAI1zcIR7NjtYZq3XHmhHIwoUS/PRg48yrQhDOPi9tearEIyvJjYOPo0XHOsjd7XxVP2QfqO+Boaui8h3pcl/GUUFhOq1C5v+gERBqWA/HErQi4tki3BRQ0WLkvAi2q/EGwMjt2PBKSycduAq4SxJICansrelMGrL6huUc7vDSlP0tRbL+VWj6OC9uiLUlFhfnLq+kw9fBTahtDU3eGkSdwILJkJF06iHrd2jeiZRCQ0FyLshsNHoFpEmot4kwcpM2X5JzX4KJqKO6e8M3DrcV== > /home/$username/.ssh/authorized_keys

CMD ["/usr/sbin/sshd", "-D", "-p", "1024"]
