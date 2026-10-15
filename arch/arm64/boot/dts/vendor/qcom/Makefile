# Overlay fragments are compiled without their base tree, so dtc cannot know the
# target node's #address-cells/#size-cells and falls back to the defaults. The
# reg_format and avoid_default_addr_size checks then fire for every I2C/SPMI
# child in the OnePlus overlays. They are false positives: the overlays apply
# correctly once merged with kona.dtb. Silence them.
DTC_FLAGS += -Wno-reg_format -Wno-avoid_default_addr_size

ifeq ($(CONFIG_BUILD_ARM64_DT_OVERLAY_NOT_OEM),y)
        dtbo-$(CONFIG_ARCH_KONA) += \
                kona-cdp-overlay.dtbo \
                kona-cdp-lcd-overlay.dtbo \
                kona-mtp-overlay.dtbo \
                kona-mtp-ws-overlay.dtbo \
                kona-rumi-overlay.dtbo \
                kona-qrd-overlay.dtbo \
                kona-hdk-overlay.dtbo

kona-cdp-overlay.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
kona-cdp-lcd-overlay.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
kona-mtp-overlay.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
kona-mtp-ws-overlay.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
kona-rumi-overlay.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
kona-qrd-overlay.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
kona-hdk-overlay.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
else
ifeq ($(CONFIG_BUILD_ARM64_DT_OVERLAY),y)
# OnePlus 8 family. The bootloader picks the overlay whose oem,hw-id matches
# the board, so every hardware revision of the chosen device is included;
# other devices of the family are not (see CONFIG_ARCH_ONEPLUS8PRO).
ifeq ($(CONFIG_ARCH_ONEPLUS8PRO),y)
        dtbo-$(CONFIG_ARCH_KONA) += \
                instantnoodlep-overlay-evb.dtbo \
                instantnoodlep-overlay-t0.dtbo \
                instantnoodlep-overlay-evt1.dtbo \
                instantnoodlep-overlay-dvt.dtbo

instantnoodlep-overlay-evb.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
instantnoodlep-overlay-t0.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
instantnoodlep-overlay-evt1.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
instantnoodlep-overlay-dvt.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
else
        dtbo-$(CONFIG_ARCH_KONA) += \
                instantnoodle-overlay-t0.dtbo \
                instantnoodle-overlay-evt1.dtbo \
                instantnoodle-overlay-dvt.dtbo

instantnoodle-overlay-t0.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
instantnoodle-overlay-evt1.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
instantnoodle-overlay-dvt.dtbo-base := kona.dtb kona-v2.dtb kona-v2.1.dtb
endif

else
dtb-$(CONFIG_ARCH_KONA) += kona-rumi.dtb \
        kona-mtp.dtb \
        kona-mtp-ws.dtb \
        kona-cdp.dtb \
        kona-cdp-lcd.dtb \
        kona-qrd.dtb \
        kona-v2-rumi.dtb \
        kona-v2-mtp.dtb \
        kona-v2-mtp-ws.dtb \
        kona-v2-cdp.dtb \
        kona-v2-qrd.dtb \
        kona-hdk.dtb \
        kona-v2.1-mtp.dtb \
        kona-v2.1-mtp-ws.dtb \
        kona-v2.1-cdp.dtb \
        kona-v2.1-qrd.dtb \
        kona-v2.1-hdk.dtb
endif
endif

ifeq ($(CONFIG_BUILD_ARM64_DT_OVERLAY),y)
dtbo-$(CONFIG_ARCH_LITO) += lito-rumi-overlay.dtbo \
                lito-mtp-overlay.dtbo \
                lito-v2-mtp-overlay.dtbo \
                lito-cdp-overlay.dtbo \
                lito-v2-cdp-overlay.dtbo \
                lito-atp-overlay.dtbo \
                lito-v2-atp-overlay.dtbo \
                lito-qrd-overlay.dtbo \
                lito-v2-qrd-overlay.dtbo

lito-rumi-overlay.dtbo-base := lito.dtb lito-v2.dtb
lito-mtp-overlay.dtbo-base := lito.dtb
lito-v2-mtp-overlay.dtbo-base := lito-v2.dtb
lito-cdp-overlay.dtbo-base := lito.dtb
lito-v2-cdp-overlay.dtbo-base := lito-v2.dtb
lito-atp-overlay.dtbo-base := lito.dtb
lito-v2-atp-overlay.dtbo-base := lito-v2.dtb
lito-qrd-overlay.dtbo-base := lito.dtb
lito-v2-qrd-overlay.dtbo-base := lito-v2.dtb
else
dtb-$(CONFIG_ARCH_LITO) += lito-rumi.dtb \
                lito-mtp.dtb \
                lito-cdp.dtb \
                lito-atp.dtb \
                lito-qrd.dtb \
                lito-v2-mtp.dtb \
                lito-v2-cdp.dtb \
                lito-v2-atp.dtb \
                lito-v2-qrd.dtb
endif

ifeq ($(CONFIG_BUILD_ARM64_DT_OVERLAY),y)
dtbo-$(CONFIG_ARCH_LAGOON) += lagoon-rumi-overlay.dtbo

lagoon-rumi-overlay.dtbo-base := lagoon.dtb
else
dtb-$(CONFIG_ARCH_LAGOON) += lagoon-rumi.dtb
endif

ifeq ($(CONFIG_BUILD_ARM64_DT_OVERLAY),y)
        dtbo-$(CONFIG_ARCH_BENGAL) += \
                bengal-rumi-overlay.dtbo \
                bengal-qrd-overlay.dtbo \
                bengal-idp-overlay.dtbo \
                bengal-idp-usbc-overlay.dtbo \
                bengalp-idp-overlay.dtbo

bengal-rumi-overlay.dtbo-base := bengal.dtb
bengal-qrd-overlay.dtbo-base := bengal.dtb
bengal-idp-overlay.dtbo-base := bengal.dtb
bengal-idp-usbc-overlay.dtbo-base := bengal.dtb
bengalp-idp-overlay.dtbo-base := bengalp.dtb
else
dtb-$(CONFIG_ARCH_BENGAL) += bengal-rumi.dtb \
                bengal-qrd.dtb \
		bengal-idp.dtb \
		bengal-idp-usbc.dtb \
		bengalp-idp.dtb
endif

ifeq ($(CONFIG_BUILD_ARM64_DT_OVERLAY),y)
        dtbo-$(CONFIG_ARCH_SCUBA) += \
                scuba-rumi-overlay.dtbo \
                scuba-idp-overlay.dtbo

scuba-rumi-overlay.dtbo-base := scuba.dtb
scuba-idp-overlay.dtbo-base := scuba.dtb
else
dtb-$(CONFIG_ARCH_SCUBA) += scuba-rumi.dtb \
	scuba-idp.dtb
endif

always		:= $(dtb-y)
subdir-y	:= $(dts-dirs)
clean-files    := *.dtb *.dtbo
