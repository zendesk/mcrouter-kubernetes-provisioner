FROM golang:1.8-alpine

LABEL MAINTAINER="Michael Laccetti <michael@laccetti.com>"

# You probably want to override this - either via CLI, or via k8s variables or samson env vars
ENV MCROUTERCONFIG=/mcrouter/mcrouter-config.json
ENV INPUTTEMPLATE=/mcr/template/mcrouter-config.tpl
ENV NAMESPACE=
ENV INCLUSTER=true
ENV KUBECONFIG=

# add any packages you may wan
RUN apk update
RUN apk add bash memcached

RUN mkdir -p /mcr/template
RUN mkdir -p /mcr/bin

ADD docker-entrypoint.sh /mcr/bin/docker-entrypoint.sh
ADD mcrouter-kuberentes-provisioner /mcr/bin/mcrouter-kuberentes-provisioner
ADD ./template/mcrouter-config.tpl /mcr/template/mcrouter-config.tpl

RUN chmod +x /mcr/bin/mcrouter-kuberentes-provisioner && \
  chmod +x /mcr/bin/docker-entrypoint.sh 

ENTRYPOINT [ "/mcr/bin/docker-entrypoint.sh" ]
#CMD tail -f /dev/null
