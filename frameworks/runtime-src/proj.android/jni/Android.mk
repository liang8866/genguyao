LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := \
../../Classes/AppDelegate.cpp \
../../Classes/WSClientNet/DBuf.cpp \
../../Classes/WSClientNet/DNetScheduler.cpp \
../../Classes/WSClientNet/DShortConnect.cpp \
../../Classes/WSClientNet/lua_netluafunc_auto.cpp \
../../Classes/WSClientNet/NetLuaFunc.cpp \
../../Classes/WSClientNet/DLongConnect.cpp \
../../Classes/WSClientNet/DNetStream.cpp \
../../Classes/customCpp/lua_custom_auto.cpp \
../../Classes/customCpp/StreakSprite.cpp \
../../Classes/customCpp/WindSprite.cpp \
../../Classes/ide-support/SimpleConfigParser.cpp \
../../Classes/WSClientNet/httpdownload.cpp \
../../Classes/customCpp/FileTools.cpp \
hellolua/main.cpp

LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../Classes/protobuf-lite \
$(LOCAL_PATH)/../../Classes/runtime \
$(LOCAL_PATH)/../../Classes \
$(LOCAL_PATH)/../../../cocos2d-x/external \
$(LOCAL_PATH)/../../../cocos2d-x/tools/simulator/libsimulator/lib

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes

# _COCOS_HEADER_ANDROID_BEGIN
# _COCOS_HEADER_ANDROID_END

LOCAL_STATIC_LIBRARIES := cocos2d_lua_static
LOCAL_STATIC_LIBRARIES += cocos2d_simulator_static

# _COCOS_LIB_ANDROID_BEGIN
# _COCOS_LIB_ANDROID_END

include $(BUILD_SHARED_LIBRARY)

$(call import-module,scripting/lua-bindings/proj.android)
$(call import-module,tools/simulator/libsimulator/proj.android)

# _COCOS_LIB_IMPORT_ANDROID_BEGIN
# _COCOS_LIB_IMPORT_ANDROID_END
