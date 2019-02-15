#!/bin/ash

line_in_file() { sed -i "/${1:?regexp}/ c${2:?line}" "${3:?file}"; }
define() { line_in_file "${1:?var}" "#define ${1} ${2?value}" "${3:?file}"; }

# go to config directory
cd "${1:?ipxe sources}/config"

# branding
#define "PRODUCT_URI" "boot.rz.semjonov.de" branding.h
#define "PRODUCT_TAG_LINE" "network kickstarting" branding.h

# colors
define COLOR_NORMAL_FG        COLOR_WHITE     colour.h
define COLOR_NORMAL_BG        COLOR_BLACK     colour.h
define COLOR_SELECT_FG        COLOR_WHITE     colour.h
define COLOR_SELECT_BG        COLOR_BLUE      colour.h
define COLOR_SEPARATOR_FG     COLOR_CYAN      colour.h
define COLOR_SEPARATOR_BG     COLOR_BLACK     colour.h

# protocols
define NET_PROTO_IPV6         ""              general.h
define DOWNLOAD_PROTO_HTTPS   ""              general.h

# included commands
define NSLOOKUP_CMD           ""              general.h
define DIGEST_CMD             ""              general.h
define IMAGE_TRUST_CMD        ""              general.h
define REBOOT_CMD             ""              general.h
define POWEROFF_CMD           ""              general.h
define CERT_CMD               ""              general.h
define NTP_CMD                ""              general.h
define PCI_CMD                ""              general.h
define TIME_CMD               ""              general.h
define VLAN_CMD               ""              general.h