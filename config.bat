@echo off
chcp 65001
setlocal enabledelayedexpansion

set myDir=%~dp0

if "%video_dir%"=="" (
    set /p video_dir="Please input Saving video dir, At last input \.:"
)

if "%stream_key%"=="" (
    set /p stream_key="Please input YouTube stream key:"
)

echo video_dir=%video_dir%> %myDir%\config.txt
echo stream_key=%stream_key%>> %myDir%\config.txt

echo "Config was saved."
pause