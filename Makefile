include theos/makefiles/common.mk

TWEAK_NAME = YTNoAutoPlay

YTNoAutoPlay_FILES = /mnt/d/codes/ytnoautoplay/YTNoAutoPlay.xm
YTNoAutoPlay_FRAMEWORKS = CydiaSubstrate UIKit Foundation
YTNoAutoPlay_LDFLAGS = -Wl,-segalign,4000

export ARCHS = armv7 arm64
YTNoAutoPlay_ARCHS = armv7 arm64 

include $(THEOS_MAKE_PATH)/tweak.mk

all::

	