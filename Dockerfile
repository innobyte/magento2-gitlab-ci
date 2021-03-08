FROM innobyte/magento2-gitlab-ci:7.2

RUN apt-get update \
   && apt-get install -y python3 python3-pip \
   && pip3 install awscli \
   && rm -rf /var/lib/apt/lists/*
