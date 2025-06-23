FROM scratch
LABEL maintainer="AOSC-dev"
ARG TARGETOS
ARG TARGETARCH
ADD "${TARGETARCH}.tar" /
CMD ["/bin/bash"]
RUN sed -i 's/no_check_dbus = false/no_check_dbus = true/' /etc/oma.toml
