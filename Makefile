ARCHS = arm64
TARGET = iphone:clang:latest:13.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = EyReqibIntro
EyReqibIntro_FILES = Tweak.x
EyReqibIntro_FRAMEWORKS = UIKit AVFoundation
EyReqibIntro_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

