ARG STEP_1_IMAGE=alpine:3.11

FROM ${STEP_1_IMAGE} AS STEP_1

ENV BUILD_PACKAGES \
  bash \
  curl \
  tar \
  openssh-client \
  sshpass \
  git \
  libssl1.1 \
  python3

RUN apk --update add --virtual build-dependencies \
  make \
  gcc \
  musl-dev \
  libffi-dev \
  openssl-dev \
  python3-dev \
  py3-psycopg2

COPY requirements.txt /tmp/requirements.txt

RUN set -x && \
  apk update && apk upgrade && \
  apk add --no-cache ${BUILD_PACKAGES} && \
  python3 -m pip install --upgrade pip && \
  python3 -m pip install -r /tmp/requirements.txt

RUN mkdir -p /etc/ansible /ansible

RUN apk del build-dependencies && \
  rm -rf /var/cache/apk/*

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PYTHONPATH /ansible/lib
ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library

WORKDIR /ansible/playbooks

CMD ["ansible-playbook"]