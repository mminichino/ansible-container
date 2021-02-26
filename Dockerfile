FROM centos:8.3.2011

LABEL maintainer="mminichino@mac.com"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.name="mminichino/ntapauto"
LABEL org.label-schema.description="NetApp Ansible Automation"
LABEL org.label-schema.url="https://github.com/mminichino/ntapauto"
LABEL org.label-schema.vcs-url="https://github.com/mminichino/ntapauto"
LABEL org.label-schema.vendor="NetApp"
LABEL org.label-schema.docker.cmd="docker run -it -v $(pwd):/local_playbooks -v ~/.ssh/id_rsa:/root/id_rsa mminichino/ntapauto:latest"

ENV PATH="${PATH}:/tools:/playbooks"

RUN mkdir /tools
COPY addAdminAccounts.sh /tools
COPY addHost.sh /tools
COPY setupAnsibleEnv.sh /tools
COPY setupLinuxEnv.sh /tools
COPY entryPoint.sh /tools
RUN chmod ug+x /tools/*.sh

RUN /tools/setupLinuxEnv.sh
RUN /tools/setupAnsibleEnv.sh

WORKDIR /playbooks

ENTRYPOINT /tools/entryPoint.sh
