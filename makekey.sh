#!/bin/sh
keytool -genkey -v -keystore kemps-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias kemps-alias

