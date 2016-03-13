#!/bin/bash
printUsage(){
  echo "------------------------USAGE-----------------------------";
  cat << EOF
Usage : $0 options
    
This script help you to create GIF animation of Android device screen

DEPENDENCIES : adb, bc, convert, perl, ffmpeg . So if you are missing something on your system
    Please install this packages and run script again

NOTE : please use only one devices at once

OPTIONS:
   -f      Output file name (screencast.gif)
   -t      Time of screencast
   -q      Quality (FPS) bigger value better quality
   -m      Mode shot (multiple pngs) or cast (record video)
   -i      Interval between taking next screenshot or interval between frames in cast mode
EOF
  echo "------------------------USAGE-----------------------------";
}
cleanup() {
    # Removing files
    rm -rf $TMP_DIR
}
handleScreenshotMode() {
    # dividing to calculate iterations
    iterations=$(bc <<< "scale=2; $TIME/$INTERVAL")
    # cast to int
    rounded=${INTERVAL/.*}
    iterations=${iterations/.*}
    echo $rounded
    # if value is to small
    if [ $rounded -lt 1 ] && [ $iterations -gt $(( TIME*5 )) ]; then
        # calculate sleep time
        iterations=$(( TIME*2 ))
    fi
    echo " $iterations screenshots will be taken"
    for (( c=1; c<=$iterations; c++ ))
    do
        capture=$(adb shell screencap -p | perl -pe 's/\x0D\x0A/\x0A/g' > "$TMP_DIR"adb-screenshot-$(date +%s%N)"$IMAGE_EXTENSION")
        if  [[ $? -ne 0 ]] ;
        then
            echo "Error occured, exiting"
            cleanup
            exit
        fi
        if [ $? -ne 0 ]; then
            echo "Error occured, exiting"
            cleanup
            exit
        fi
        sleep $INTERVAL
    done
    # Converting to gif animation
    convert "$TMP_DIR""*$IMAGE_EXTENSION" $FILE_NAME
    if  [[ $? -ne 0 ]] ;
        then
            echo "Error occured, exiting"
            cleanup
            exit
    fi
}
handleScreencastMode() {
    mkdir "$TMP_DIR$FRAME_DIR"
    adb shell screenrecord "$VIDEO_PATH" &
    pid=$!
    if [ $? -ne 0 ]; then
        echo "Error occured, exiting"
        cleanup
        exit
    fi
    echo "Process started PID : $pid , recording video"
    sleep $TIME
    echo "Recorded, stopping process "
    # stopping process , -2 SIGINT doesn't work unfortunatelly
    res=$(kill -9 "$pid" 2>&1)
    echo "Downloading video"
    # let android to process video before pulling
    if [ $TIME -gt 5 ]; then
        # calculate sleep time
        sleep $(( $TIME / 3 ))
    else
        # sleep default
        sleep 2
    fi

    adb pull "$VIDEO_PATH" "$TMP_DIR"
    if [ $? -ne 0 ]; then
        echo "Error occured, exiting"
        cleanup
        exit
    fi
    echo "Converting video into frames"
    ffmpeg -i "$TMP_DIR$VIDEO_FILE_NAME"  -r "$DEFAULT_FPS" "$TMP_DIR$FRAME_DIR"'/frame-%03d.jpg' &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error occured, exiting"
        cleanup
        exit
    fi
    INTERVAL=${INTERVAL/.*}
    # if value is to small
    if [ $INTERVAL -lt 1 ]; then
        # calculate sleep time
        INTERVAL=$DEFAULT_FPS
    fi
    echo "Converting frames into gif animation"
    convert -delay "$INTERVAL" -loop 0 "$TMP_DIR$FRAME_DIR"'/*.jpg' $FILE_NAME
    if [ $? -ne 0 ]; then
        echo "Error occured, exiting"
        cleanup
        exit
    fi
}
MODE_SCREENSHOT="shot"
MODE_SCREENCAST="cast"
MODE=$MODE_SCREENCAST
DEFAULT_FPS=5
FRAME_DIR="frames"
VIDEO_FILE_NAME="screencast.mp4"
VIDEO_PATH="/sdcard/"
IMAGE_EXTENSION=".png"
TMP_DIR="/tmp/android-screencast/"
FILE_NAME="screen-animation.gif"
VIDEO_PATH+=$VIDEO_FILE_NAME

# Five seconds by default
TIME=5 
# O.1 second interval by default, only available for screenshots
INTERVAL=0.1
while getopts “ht:i:f:v:m:q” OPTION
do
     case $OPTION in
         h)
             printUsage
             exit 1
             ;;
         t)
             TIME=$OPTARG
             ;;
         m)
             MODE=$OPTARG
             ;;
         i)
             INTERVAL=$OPTARG
             ;;
         f)
             FILE_NAME=$OPTARG
             ;;
         q)
             DEFAULT_FPS=$OPTARG
             ;;
         ?)
             printUsage
             exit
             ;;
     esac
done
# create temp dir
if [ -d $TMP_DIR ]; then 
    echo "Directory $TMP_DIR already exists, removing"
    cleanup

fi
mkdir $TMP_DIR
case $MODE in
$MODE_SCREENCAST)
    echo -e "Screencast mode "
    handleScreencastMode
    ;;
$MODE_SCREENSHOT)
    echo -e "Screenshot mode "
    handleScreenshotMode
    ;;
*)
    echo "Invalid mode, exiting"
    cleanup
    exit
    ;;
esac
echo "Cleaning up"
cleanup
echo "Successfully created, press any key to continue"
read
