################################################################################
#      This file is part of LibreELEC - https://libreelec.tv
#      Copyright (C) 2017-present Team LibreELEC
#
#  LibreELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  LibreELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with LibreELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="mali-rockchip"
PKG_VERSION="4ab65dc"
PKG_SHA256="246343d3b897b5070a08cc2b795b51b9e1d3c3250fdd62adf507b3f3bd3cd830"
PKG_ARCH="arm aarch64"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/rockchip-linux/libmali"
PKG_URL="https://github.com/rockchip-linux/libmali/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_DIR="libmali-$PKG_VERSION*"
PKG_SECTION="graphics"
PKG_SHORTDESC="mali-rockchip: OpenGL ES user-space binary for the ARM Mali GPU family"
PKG_LONGDESC="mali-rockchip: OpenGL ES user-space binary for the ARM Mali GPU family"
PKG_AUTORECONF="no"

if [ "$TARGET_ARCH" = "arm" ]; then
  LIBMALI_ARCH="arm-linux-gnueabihf"
elif [ "$TARGET_ARCH" = "aarch64" ]; then
  LIBMALI_ARCH="aarch64-linux-gnu"
fi

if [ "$DISPLAYSERVER" = "wayland" ]; then
  LIBMALI_VARIANT="wayland"
else
  LIBMALI_VARIANT="gbm"
fi

if [ "$MALI_FAMILY" = "t760" ]; then
  LIBMALI_FILE="libmali-midgard-t76x-r13p0-r0p0-$LIBMALI_VARIANT.so"
elif [ "$MALI_FAMILY" = "t860" ]; then
  LIBMALI_FILE="libmali-midgard-t86x-r13p0-$LIBMALI_VARIANT.so"
elif [ "$MALI_FAMILY" = "450" ]; then
  LIBMALI_FILE="libmali-utgard-450-r7p0-$LIBMALI_VARIANT.so"
elif [ "$MALI_FAMILY" = "400" ]; then
  LIBMALI_FILE="libmali-utgard-400-r7p0-$LIBMALI_VARIANT.so"
else
  exit 1
fi

configure_target() {
  if [ ! -f "$PKG_BUILD/lib/$LIBMALI_ARCH/$LIBMALI_FILE" ]; then
    echo "ERROR: $LIBMALI_ARCH/$LIBMALI_FILE does not exist!"
    exit 1
  fi
}

make_target() {
  : # nothing
}

makeinstall_target() {
  cd $PKG_BUILD

  mkdir -p $SYSROOT_PREFIX/usr/include
    cp -PRv include/EGL $SYSROOT_PREFIX/usr/include
    cp -PRv include/GLES $SYSROOT_PREFIX/usr/include
    cp -PRv include/GLES2 $SYSROOT_PREFIX/usr/include
    if [ "$MALI_FAMILY" = "t760" -o "$MALI_FAMILY" = "t860" ]; then
      cp -PRv include/GLES3 $SYSROOT_PREFIX/usr/include
    fi
    cp -PRv include/KHR $SYSROOT_PREFIX/usr/include
    cp -PRv include/gbm.h $SYSROOT_PREFIX/usr/include

  mkdir -p $SYSROOT_PREFIX/usr/lib/pkgconfig
    cp -PRv $PKG_DIR/pkgconfig/*.pc $SYSROOT_PREFIX/usr/lib/pkgconfig
    if [ "$LIBMALI_VARIANT" != "wayland" ]; then
      rm -fv $SYSROOT_PREFIX/usr/lib/pkgconfig/wayland-egl.pc
    fi

  mkdir -p $SYSROOT_PREFIX/usr/lib
    cp -PRv lib/$LIBMALI_ARCH/$LIBMALI_FILE $SYSROOT_PREFIX/usr/lib
    ln -sfv $LIBMALI_FILE $SYSROOT_PREFIX/usr/lib/libmali.so
    ln -sfv libmali.so $SYSROOT_PREFIX/usr/lib/libMali.so
    ln -sfv libmali.so $SYSROOT_PREFIX/usr/lib/libEGL.so
    ln -sfv libmali.so $SYSROOT_PREFIX/usr/lib/libGLESv2.so
    ln -sfv libmali.so $SYSROOT_PREFIX/usr/lib/libgbm.so

  mkdir -p $INSTALL/usr/lib
    cp -PRv lib/$LIBMALI_ARCH/$LIBMALI_FILE $INSTALL/usr/lib
    ln -sfv $LIBMALI_FILE $INSTALL/usr/lib/libmali.so
    ln -sfv libmali.so $INSTALL/usr/lib/libMali.so
    ln -sfv libmali.so $INSTALL/usr/lib/libEGL.so
    ln -sfv libmali.so $INSTALL/usr/lib/libGLESv2.so
    ln -sfv libmali.so $INSTALL/usr/lib/libgbm.so

  mkdir -p $INSTALL/usr/lib/modules-load.d
    if [ "$MALI_FAMILY" = "t760" -o "$MALI_FAMILY" = "t860" ]; then
      echo "mali_kbase" > $INSTALL/usr/lib/modules-load.d/mali.conf
    elif [ "$MALI_FAMILY" = "450" -o "$MALI_FAMILY" = "400" ]; then
      echo "mali" > $INSTALL/usr/lib/modules-load.d/mali.conf
    fi
}
