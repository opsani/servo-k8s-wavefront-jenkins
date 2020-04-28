FROM python:3.6-slim

LABEL maintainer="robert@opsani.com"
LABEL description="A servo for opsani.com optimization"
LABEL plugins="servo-k8s, servo-wavefront, servo-jenkins"
LABEL version="0.1.0"
WORKDIR /servo

ADD  https://storage.googleapis.com/kubernetes-release/release/v1.16.2/bin/linux/amd64/kubectl /usr/local/bin/

# Install dependencies
RUN apt update && apt -y install procps tcpdump curl wget
RUN pip3 install requests PyYAML python-dateutil 

RUN mkdir -p measure.d

ADD https://raw.githubusercontent.com/opsani/servo-jenkins/master/load measure.d/measure-jenkins
ADD https://raw.githubusercontent.com/opsani/servo-wavefront/master/measure measure.d/measure-wavefront
ADD https://raw.githubusercontent.com/opsani/servo/master/measure.py measure.d/

# Install servo
ADD https://raw.githubusercontent.com/opsani/servo/master/servo \
    https://raw.githubusercontent.com/opsani/servo/master/adjust.py \
    https://raw.githubusercontent.com/opsani/servo/master/measure.py \
    https://raw.githubusercontent.com/opsani/servo-k8s/master/adjust \
    https://raw.githubusercontent.com/opsani/servo-magg/master/measure \
    /servo/

RUN chmod a+rwx /servo/adjust /servo/measure /servo/servo /usr/local/bin/kubectl /usr/local/bin/vegeta
RUN chmod a+r /servo/adjust.py /servo/measure.py measure.d/measure.py
RUN chmod a+rwx /servo/measure.d/measure-jenkins /servo/measure.d/measure-wavefront

ENV PYTHONUNBUFFERED=1

ENTRYPOINT [ "python3", "servo" ]
