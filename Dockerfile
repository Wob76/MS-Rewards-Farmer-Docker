FROM python:slim

# ARG CHROMEVERSION
ARG CHROMEURL

ENV MSR_CHROMEVERSION=$CHROMEVERSION
ENV CHROMEDLURL=$CHROMEURL

# download and install google chrome and xvfb
RUN apt-get update && apt-get install -y wget git && \
  wget -O /tmp/chrome.deb $CHROMEDLURL && \
  apt-get install -y /tmp/chrome.deb xvfb && \
  rm -f /tmp/chrome.deb && \
  google-chrome --version

# create the app directory
WORKDIR /app

# Pulled from Official Dockerfile
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y chromium chromium-driver cron locales && \
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

# clone the project
RUN git clone --single-branch --branch develop https://github.com/klept0/MS-Rewards-Farmer.git ./

# install dependencies
RUN pip install --root-user-action=ignore -r requirements.txt

# setting display enviroment stuff
ENV DISPLAY=:99
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

# copy entrypoint script
COPY entrypoint.sh ./

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["python3", "main.py"]
