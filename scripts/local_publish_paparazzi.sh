#!/bin/sh

./gradlew mavenLocalize

./gradlew clean \
  publishMavenPublicationToMavenLocal \
  paparazzi-gradle-plugin:publishPluginMavenPublicationToMavenLocal \
  paparazzi-gradle-plugin:publishPaparazziPluginMarkerMavenPublicationToMavenLocal\
  --no-parallel
