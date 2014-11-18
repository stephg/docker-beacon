FROM fedora:latest
MAINTAINER Stephan Günther <steph.guenther@gmail.com>

# prepare system
RUN yum upgrade -y

# install golang
RUN yum install -y golang git

# install beacon
ENV GOPATH /usr/share/go
RUN mkdir -p $GOPATH
RUN go get -v github.com/BlueDragonX/beacon

# add startup script
COPY run_beacon.sh /usr/local/bin/run_beacon

# go!
CMD ["/usr/local/bin/run_beacon", "/tmp/beacon.yml"]
