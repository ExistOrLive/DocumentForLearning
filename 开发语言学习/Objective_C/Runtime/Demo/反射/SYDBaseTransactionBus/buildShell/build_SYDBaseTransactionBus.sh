#!/bin/bash

#unlock the keychain
# security unlock-keychain -p softda
#security unlock-keychain -p softda

echo "<------- Begin SYDBaseTransactionBus build  --------->"

#Save current path
CODE_PATH=`pwd`

echo "<--- current path ""${CODE_PATH}""--->"

#The following compile Bulgaria iPhone version
#goto code dir
cd ..

mkdir build
rm -rf ./build/*

rm -rf ../../libSYDBaseTransactionBus.a

security unlock-keychain -p softda

#call xcodebuild
sudo xcode-select --switch "/Applications/Xcode.app"
xcodebuild -target "SYDBaseTransactionBus" -configuration "Release" -sdk iphoneos

#cp
cp "./build/Release-iphoneos/libSYDBaseTransactionBus.a" ../../libSYDBaseTransactionBus.a


echo "<------- Finish SYDBaseTransactionBus build  --------->"






