# ---------- compile ipxe binaries ----------

# alpine base image
FROM alpine:latest as ipxe

# install build requirements
RUN apk add --no-cache git gcc make musl-dev openssl perl xz-dev

# clone source code
RUN git clone --depth 1 git://git.ipxe.org/ipxe.git /ipxe

# prepare build
ARG MAKEFLAGS=-j$(nproc)
WORKDIR /ipxe/src

# apply configuration tweaks
COPY configure.sh .
RUN ash configure.sh $PWD

# build bios and efi targets
RUN make \
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
ENV MENU=http://example.local/menu.ipxe

CMD exec dnsmasq -d -q --port 0 \
  --enable-tftp --tftp-root=/tftp \
  --dhcp-range="${SUBNET},proxy" \
  --dhcp-userclass="set:ipxe,iPXE" \
  --pxe-service="tag:#ipxe,x86PC,'chainload bios --> ipxe',undionly.kpxe" \
  --pxe-service="tag:ipxe,x86PC,'load menu',${MENU}" \
  --pxe-service="tag:#ipxe,BC_EFI,'chainload bc_efi --> ipxe',ipxe.efi" \
  --pxe-service="tag:ipxe,BC_EFI,'load menu',${MENU}" \
  --pxe-service="tag:#ipxe,x86-64_EFI,'chainload efi --> ipxe',ipxe.efi" \
  --pxe-service="tag:ipxe,x86-64_EFI,'load menu',${MENU}"
