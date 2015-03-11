#sshd
#
## VERSION  0.9.1
#
FROM ubuntu:14.04
MAINTAINER Tien Nguyen <thanhtien522@gmail.com>

# Install GNU compiler
RUN apt-get update && apt-get install -y gcc g++ nano cmake

# Install python 2.7.3
COPY source/Python-2.7.3.tgz /root/
RUN tar -zxvf /root/Python-2.7.3.tgz -C /root/
WORKDIR /root/Python-2.7.3
RUN ./configure
RUN make
RUN make install

# Install gfortran and ssh service
RUN apt-get install -y libibnetdisc-dev gfortran openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:screencat' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profiles"
RUN echo "export VISIBLE=now" >> /etc/profile

# Copy and extract OpenMPI source
COPY source/openmpi-1.8.4.tar.gz /root/
RUN tar -zxvf /root/openmpi-1.8.4.tar.gz -C /root/

#Compile and install OpenMPI at /root/.openmpi
WORKDIR /root/openmpi-1.8.4/
RUN ./configure --prefix="/root/.openmpi"
RUN make all install
ENV LD_LIBRARY_PATH /root/.openmpi/lib
ENV PATH="$PATH:/root/.openmpi/bin"

# Install Metis for OpenTeleMac
COPY source/metis-5.1.0.tar.gz /root/
RUN tar -zxvf /root/metis-5.1.0.tar.gz -C /root/
WORKDIR /root/metis-5.1.0
RUN make config
RUN make install

# Copy OpenTeleMac source and compile.
COPY source/telemac /root/telemac

# Configure ENV for OpenTeleMac
ENV PATH="$PATH:/root/telemac/v6p2r1/pytel"
ENV SYSTELCFG=/root/telemac/v6p2r1/config/systel.cis-ubuntu.cfg

# Compile OpenTeleMac
RUN compileTELEMAC.py

# Copy script
COPY ssh /root/ssh

# Install expect
RUN apt-get -y install expect


# Configure SSH service.
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

