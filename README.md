Android Screen to GIF
=====================

The best way to show how library works is to show video or animation.
Especially for Android, most of libraries has something that affects UI

So this is `Bash` script that make it easier to capture android screen into the `GIF` file.


Usage 
-------------------------

This script help you to create GIF animation of Android device screen

**DEPENDENCIES** : adb, bc, convert, perl, ffmpeg .   
So if you are missing something on your system, please install this packages and run script again

**NOTE** : please use only one devices at once

**OPTIONS:**
   - f      Output file name (screencast.gif)
   - t      Time of screencast
   - q      Quality (FPS) bigger value better quality
   - m      Mode shot (multiple pngs) or cast (record video)
   - i      Interval between taking next screenshot or interval between frames in cast mode

License
-------

    Copyright 2016 Oleksandr Molochko

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
