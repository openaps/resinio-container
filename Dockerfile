
FROM resin/edison-python:latest

RUN apt-get update && apt-get install -y python python-dev python-pip

# Install Dropbear.
RUN apt-get install -y dropbear
RUN pip install flask


# Install openaps
RUN apt-get install -y git python python-dev python-setuptools python-software-properties python-numpy
RUN easy_install -ZU openaps
## **Install udev-rules**
RUN openaps-install-udev-rules
RUN activate-global-python-argcomplete



RUN easy_install openapscontrib.mmhistorytools

#### **Install [mmglucosetools](https://github.com/loudnate/openaps-mmglucosetools)**
RUN easy_install openapscontrib.mmglucosetools

#### **Install [openaps-predict](https://github.com/loudnate/openaps-predict)**
RUN easy_install openapscontrib.predict

RUN openaps --version

RUN mkdir -p /opt/monitor
RUN git clone git://github.com/loudnate/openaps-monitor.git /opt/monitor
RUN cd /opt/monitor && pip install -r requirements.txt


COPY . /app
CMD ["bash", "/app/start.sh"]

