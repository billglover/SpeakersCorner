#!/bin/bash
f=$(pwd)

# App Icon
sips --resampleWidth 180 "${f}/${1}" --out "${f}/iPhoneIcon@3x.png"
sips --resampleWidth 120 "${f}/${1}" --out "${f}/iPhoneIcon@2x.png"
sips --resampleWidth 152 "${f}/${1}" --out "${f}/iPadIcon@2x.png"
sips --resampleWidth 76 "${f}/${1}" --out "${f}/iPadIcon.png"

# App Icon for the App Store
sips --resampleWidth 512 "${f}/${1}" --out "${f}/iTunesArtwork.png"
sips --resampleWidth 1024 "${f}/${1}" --out "${f}/iTunesArtwork@2x.png"

# Spotlight Icon
sips --resampleWidth 120 "${f}/${1}" --out "${f}/iPhoneSpotlight@3x.png"
sips --resampleWidth 80 "${f}/${1}" --out "${f}/iPhoneSpotlight@2x.png"
sips --resampleWidth 80 "${f}/${1}" --out "${f}/iPadSpotlight@2x.png"
sips --resampleWidth 40 "${f}/${1}" --out "${f}/iPadSpotlight.png"

# Settings Icon
sips --resampleWidth 87 "${f}/${1}" --out "${f}/iPhoneSettings@3x.png"
sips --resampleWidth 58 "${f}/${1}" --out "${f}/iPhoneSettings@2x.png"
sips --resampleWidth 29 "${f}/${1}" --out "${f}/iPhoneSettings.png"
sips --resampleWidth 58 "${f}/${1}" --out "${f}/iPadSettings@2x.png"
sips --resampleWidth 29 "${f}/${1}" --out "${f}/iPadSettings.png"

# Watch Icons
sips --resampleWidth 80 "${f}/${1}" --out "${f}/AppleWatchHome@2x.png"
sips --resampleWidth 58 "${f}/${1}" --out "${f}/AppleWatchCompainionSettings@2x.png"
sips --resampleWidth 87 "${f}/${1}" --out "${f}/AppleWatchCompainionSettings@3x.png"
sips --resampleWidth 48 "${f}/${1}" --out "${f}/AppleWatchNotificationCenter@38.png"
sips --resampleWidth 55 "${f}/${1}" --out "${f}/AppleWatchNotificationCenter@42.png"
sips --resampleWidth 88 "${f}/${1}" --out "${f}/AppleWatchLongLookNotification@42.png"
sips --resampleWidth 172 "${f}/${1}" --out "${f}/AppleWatchShortLookNotification@38.png"
sips --resampleWidth 196 "${f}/${1}" --out "${f}/AppleWatchShortLookNotification@42.png"

# Source:
# https://gist.github.com/jessedc/837916
