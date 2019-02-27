# Copyright (c) 2019 Anton Semjonov
# Licensed under the GPL-3.0 License or later versions at your discretion

# ---------- compile ipxe binaries ----------

# alpine base image
FROM alpine:latest as ipxe

# install build requirements
RUN apk add --no-cache git gcc make musl-dev openssl perl xz-dev

# clone source code
RUN git clone --depth 1 git://git.ipxe.org/ipxe.git /ipxe

# prepare build and apply configuration tweaks
WORKDIR /ipxe/src
ARG MAKEFLAGS=
COPY config/* ./config/local/
COPY userclass.ipxe ./

# build bios and efi targets with embedded user-class script
RUN make EMBED=userclass.ipxe \
  bin-i386-pcbios/undionly.kpxe \
  bin-x86_64-efi/ipxe.efi

# ---------- create dnsmasq image with tftp ----------

# alpine base image
FROM alpine:latest

# install dnsmasq
RUN apk add --no-cache dnsmasq

# copy ipxe binaries
WORKDIR /tftp
COPY --from=ipxe \
  /ipxe/src/bin-x86_64-efi/ipxe.efi \
  /ipxe/src/bin-i386-pcbios/undionly.kpxe \
  ./

# prepare default run command
ENV SUBNET=192.168.1.1
ENV CHAIN=unconfigured
ENV DNSMASQ_OPTS=

CMD exec dnsmasq -d -q --port 0 \
  --enable-tftp --tftp-root=/tftp \
  --dhcp-range="${SUBNET},proxy" \
  --dhcp-userclass="set:ipxe,ipxeboot" \
  --pxe-service="tag:#ipxe,x86PC,'load ipxeboot (bios)',undionly.kpxe" \
  --pxe-service="tag:ipxe,x86PC,'load menu',${CHAIN}" \
  --pxe-service="tag:#ipxe,BC_EFI,'load ipxeboot (bc_efi)',ipxe.efi" \
  --pxe-service="tag:ipxe,BC_EFI,'load menu',${CHAIN}" \
  --pxe-service="tag:#ipxe,x86-64_EFI,'load ipxeboot (efi)',ipxe.efi" \
  --pxe-service="tag:ipxe,x86-64_EFI,'load menu',${CHAIN}" \
  ${DNSMASQ_OPTS}
