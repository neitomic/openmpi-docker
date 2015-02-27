#sshd

# VERSION  0.0.2

FROM ubuntu:14.04
MAINTAINER Tien Nguyen <thanhtien522@gmail.com>

RUN apt-get update && apt-get install -y openssh-server gcc g++ libibnetdisc-dev nano
RUN mkdir /var/run/sshd
RUN echo 'root:screencat' | chpasswd
run sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profiles"
RUN echo "export VISIBLE=now" >> /etc/profile

# For build and install OpenMPI
RUN wget https://www.dropbox.com/s/ylloqxrpyay2co9/openmpi-1.8.4.tar.gz
RUN tar -zxvf openmpi-1.8.4.tar.gz


EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
