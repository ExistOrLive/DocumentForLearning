#!/bin/sh
set -x
/usr/bin/xcrun -sdk macosx.internal clang++ -Wall -mmacosx-version-min=10.12 -arch x86_64 -std=c++11 "${SRCROOT}/markgc.cpp" -o "${BUILT_PRODUCTS_DIR}/markgc"
"${BUILT_PRODUCTS_DIR}/markgc" "${BUILT_PRODUCTS_DIR}/libobjc.A.dylib"
