Paparazzi
========

Nick Edit
-------

## Overview
This repo has been modified to target `android sdk 31`. I've pulled in the latest layout_lib from 
android studio and added scripts to make it easier to manage the local maven repo.

To get everything setup in your local environment:
- run `./scripts/set_local_maven.sh`
- run `./scripts/local_publish_layout_lib.sh` (this will take awhile)
- run `./scripts/local_publish_paparazzi.sh`

## State of the world
Everything compiles but when I try and run the tests in the sample project the layout_lib crashes with the following JNI error:
```
SEVERE: broken: Native layoutlib failed to load
java.lang.UnsatisfiedLinkError: unsupported JNI version 0xFFFFFFFF required by /Users/nicholas.cipollo/.gradle/caches/transforms-3/9db22b925de80d2eefb9d7b596fb4f8f/transformed/layoutlib-native-macosx-2021.1.1-573f0704/data/mac/lib64/libandroid_runtime.dylib
	at java.base/java.lang.ClassLoader$NativeLibrary.load0(Native Method)
	at java.base/java.lang.ClassLoader$NativeLibrary.load(ClassLoader.java:2442)
	at java.base/java.lang.ClassLoader$NativeLibrary.loadLibrary(ClassLoader.java:2498)
	at java.base/java.lang.ClassLoader.loadLibrary0(ClassLoader.java:2694)
	at java.base/java.lang.ClassLoader.loadLibrary(ClassLoader.java:2627)
	at java.base/java.lang.Runtime.load0(Runtime.java:768)
	at java.base/java.lang.System.load(System.java:1837)
	at com.android.layoutlib.bridge.Bridge.loadNativeLibraries(Bridge.java:720)
	at com.android.layoutlib.bridge.Bridge.loadNativeLibrariesIfNeeded(Bridge.java:695)
	at com.android.layoutlib.bridge.Bridge.init(Bridge.java:178)
	at app.cash.paparazzi.internal.Renderer.prepare(Renderer.kt:84)
	at app.cash.paparazzi.Paparazzi.prepare(Paparazzi.kt:133)
	at app.cash.paparazzi.Paparazzi$apply$statement$1.evaluate(Paparazzi.kt:106)
	at app.cash.paparazzi.agent.AgentTestRule$apply$1.evaluate(AgentTestRule.kt:17)
	...
```

## General Info
- Paparazzi utilizes the preview manager from Android Studio to draw screenshots on the JVM (i.e not within an emulator or device)
- It does this via layoutlib. This is an open source tool which google publishes. 
- The currently published paparazzi is using a layoutlib which isn't compatible with android 31.
- This branch fetches the very latest layout lib from Android Studio 🐝.


Original Intro
-------
An Android library to render your application screens without a physical device or emulator.

```kotlin
class LaunchViewTest {
  @get:Rule
  val paparazzi = Paparazzi(
    deviceConfig = PIXEL_5,
    theme = "android:Theme.Material.Light.NoActionBar"
    // ...see docs for more options 
  )
 
  @Test
  fun simple() {
    val view = paparazzi.inflate<LaunchView>(R.layout.launch)
    // or... 
    // val view = LaunchView(paparazzi.context)
    
    view.setModel(LaunchModel(title = "paparazzi"))
    paparazzi.snapshot(view)
  }
}
```

See the [project website][paparazzi] for documentation and APIs.

Tasks
-------
```
$ ./gradlew sample:testDebug
```

Runs tests and generates an HTML report at `sample/build/reports/paparazzi/` showing all 
test runs and snapshots. 

```
$ ./gradlew sample:recordPaparazziDebug
```

Saves snapshots as golden values to a predefined source-controlled location 
(defaults to `src/test/snapshots`).

```
$ ./gradlew sample:verifyPaparazziDebug
```

Runs tests and verifies against previously-recorded golden values.


For more examples, check out the [sample][sample] project.

Git LFS
--------
It is recommended you use [Git LFS][lfs] to store your snapshots.  Here's a quick setup:

```bash
$ brew install git-lfs
$ git config core.hooksPath  # optional, confirm where your git hooks will be installed
$ git lfs install --local
$ git lfs track **/snapshots/**/*.png
$ git add .gitattributes
```

On CI, you might set up something like:

`$HOOKS_DIR/pre-receive`
```bash
# compares files that match .gitattributes filter to those actually tracked by git-lfs
diff <(git ls-files ':(attr:filter=lfs)' | sort) <(git lfs ls-files -n | sort) >/dev/null

ret=$?
if [[ $ret -ne 0 ]]; then
  echo >&2 "This remote has detected files committed without using Git LFS. Run 'brew install git-lfs && git lfs install' to install it and re-commit your files.";
  exit 1;
fi
```

`your_build_script.sh`
```bash
if [[ is running snapshot tests ]]; then
  # fail fast if files not checked in using git lfs
  "$HOOKS_DIR"/pre-receive
  git lfs install --local
  git lfs pull
fi
```

Jetifier
--------

If using Jetifier to migrate off Support libraries, add the following to your `gradle.properties` to
exclude bundled Android dependencies.

```text
android.jetifier.ignorelist=android-base-common,common
```

Releases
--------

Our [change log][changelog] has release history.

Using plugin application:
```groovy
buildscript {
  repositories {
    mavenCentral()
    google()
  }
  dependencies {
    classpath 'app.cash.paparazzi:paparazzi-gradle-plugin:0.9.3'
  }
}

apply plugin: 'app.cash.paparazzi'
```

Using the plugins DSL:
```groovy
plugins {
  id 'app.cash.paparazzi' version '0.9.3'
}
```

Snapshots of the development version are available in [Sonatype's `snapshots` repository][snap].

```groovy
 repositories {
   // ...
   maven {
     url 'https://oss.sonatype.org/content/repositories/snapshots/'
   }
 }
```

Known Limitations
-------

#### Running Tests from the IDE
```
java.lang.NullPointerException
  at java.base/java.io.File.<init>(File.java:278)
  at app.cash.paparazzi.EnvironmentKt.detectEnvironment(Environment.kt:36)
```
Running tests from the IDE requires Android Studio Arctic Fox or later.

#### Could not find ... resource matching value 0x... (resolved name: ...) in current configuration.
```
Could not find dimen resource matching value 0x10500C0 (resolved name: config_scrollbarSize) in current configuration.
android.content.res.Resources$NotFoundException: Could not find dimen resource matching value 0x10500C0 (resolved name: config_scrollbarSize) in current configuration.

Could not find integer resource matching value 0x10E00B4 (resolved name: config_screenshotChordKeyTimeout) in current configuration.
android.content.res.Resources$NotFoundException: Could not find integer resource matching value 0x10E00B4 (resolved name: config_screenshotChordKeyTimeout) in current configuration.
```
`compileSdkVersion` has to be 29 or higher.
```groovy
android {
  compileSdkVersion 29
}
```

License
-------

```
Copyright 2019 Square, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

 [changelog]: https://cashapp.github.io/paparazzi/changelog/
 [paparazzi]: https://cashapp.github.io/paparazzi/
 [sample]: https://github.com/cashapp/paparazzi/tree/master/sample
 [snap]: https://oss.sonatype.org/content/repositories/snapshots/app/cash/paparazzi/
 [lfs]: https://git-lfs.github.com/
