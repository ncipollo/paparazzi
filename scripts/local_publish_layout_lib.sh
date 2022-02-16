#!/bin/sh

./gradlew mavenLocalize

./gradlew publishMavenNativeLibraryPublicationToMavenLocal
