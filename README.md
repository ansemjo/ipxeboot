# ipxeboot

Ensure that network boot clients load an embedded iPXE binary and then chain a script or binary of
your choice. No configuration on your router required.

## Usage

Start the container, specifying your subnet and the chainload target as environment variables:

    docker run --net host -d --restart=always \
      -e SUBNET=192.168.1.1 \
      -e CHAIN=http://boot.local/menu.ipxe \
      ansemjo/ipxeboot

Check the [iPXE documentation](http://ipxe.org/scripting) on pointers on how to write scripts and
menus.

## Concepts

### DHCP Proxy

When deploying [matchbox](https://github.com/coreos/matchbox), I learned about the concept of DHCP
proxies. Those are DHCP servers that only react to certain types or parts of requests. For example
[dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) can respond with _only_ the parts necessary
for network booting -- IP address assignment etc. is still done by your router.

Check the [dnsmasq manpage](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) for the
`--dhcp-range` and its `proxy` keyword for details.

### `user-class`

PXE clients send a specific `user-class` with their request and DHCP servers can differentiate those
and serve different replies per class. As such, dnsmasq can use `--dhcp-userclass` to detect clients
that already use iPXE, for example. Tagging those and using said tag in `--pxe-service` allows you
to serve different binaries to your clients and ensure that all network bootable clients always use
iPXE.

This container goes one step further and ensures that all clients use _this specific_ embedded iPXE
binary to ensure that all clients use the same feature set. The default iPXE client of `libvirt`
virtual machines for some reason does not contain support for a serial console, for example.

## Building

You can compile the iPXE binaries and build the container image yourself, of course. Check the
[dockerfile](dockerfile) to see the build procedure.

    docker build -t ipxeboot .

### Configure iPXE

The files in [config](config/) are copied into the iPXE source tree under `src/config/local/` before
compilation. They enable certain features, tweak the branding and change the color scheme ...

See http://ipxe.org/buildcfg for a list of useful build options.
