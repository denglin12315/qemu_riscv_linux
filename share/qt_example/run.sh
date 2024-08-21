export QT_HOME=/opt/qt-5.15.10/                             # Qt库路径
export QT_QPA_FB_DRM=1                                      # 启用FB_DRM
export QT_QPA_GENERIC_PLUGINS=evdevkeyboard                 # 启用键盘插件
export QT_QPA_GENERIC_PLUGINS=evdevmouse                    # 启用鼠标插件
export QT_QPA_EVDEV_MOUSE_PARAMETERS=/dev/input/event0      # 鼠标设备
export QT_QPA_EVDEV_KEYBOARD_PARAMETERS=/dev/input/event1   # 键盘设备
export QT_QPA_FONTDIR=$QT_HOME/lib/fonts                    # 字体路径
export QT_PLUGIN_PATH=$QT_HOME/plugins                      # 插件路径
export QT_QPA_PLATFORM=linuxfb:fb=/dev/fb0                  # fb设备
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$QT_HOME/lib"      # 库路径

export QT_QPA_FB_DRM=1
export QT_PLUGIN_PATH=$QT_HOME/plugins

./output/analogclock
