FROM scratch
LABEL maintainer="AOSC-dev"
ARG TARGETOS
ARG TARGETARCH
ADD "${TARGETARCH}.tgz" /
CMD ["/bin/bash"]
#RUN sed -i 's/*               -       nice/#*               -       nice/' /etc/security/limits.conf
