#!/bin/bash

# Download Cursor IDE
wget https://downloader.cursor.sh/linux/appImage/x64 -O ./Cursor_orig.AppImage
chmod +x ./Cursor_orig.AppImage

# Extract the AppImage
./Cursor_orig.AppImage --appimage-extract
rm ./Cursor_orig.AppImage

# Fix it by replacing all occurrences of ",minHeight" with ",frame:false,minHeight"
TARGET_FILE="squashfs-root/resources/app/out/vs/code/electron-main/main.js"
sed -i 's/,minHeight/,frame:false,minHeight/g' "$TARGET_FILE"

# Download appimagetool
wget https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -O ./appimagetool-x86_64.AppImage
chmod +x ./appimagetool-x86_64.AppImage

# Repackage the AppImage using appimagetool
./appimagetool-x86_64.AppImage squashfs-root/

# Cleaning Up
rm ./appimagetool-x86_64.AppImage
rm -rf squashfs-root/