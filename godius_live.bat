@echo off
chcp 65001
setlocal enabledelayedexpansion

set myDir=%~dp0

:: Copyright
set copyright=-vf "format=yuv420p,drawtext=fontfile='C:/WINDOWS/Fonts/arial.ttf':text='Copyright GODIUS by Lionsfilm Co., Ltd.':bordercolor=white:borderw=3:x=3:y=3"

:: Read config
for /f "usebackq tokens=1,2 delims==" %%i in ("%myDir%config.txt") do (
    set %%i=%%j
)

if "%video_dir%"=="" (
    echo "Please set config."
    exit /b
)

if "%stream_key%"=="" (
    echo "Please set config."
    exit /b
)

:: Create selecter to set sound device
echo "Now displaying media device's lists..."
ffmpeg -list_devices true -f dshow -i dummy 2> %myDir%devices_temp.txt

:: Set device attr
findstr /r "@device" %myDir\%devices_temp.txt > %myDir%devices.txt

:: List of devices
set /a dev_count=0

for /f "tokens=*" %%i in (devices.txt) do (
    set "line=%%i"
    
    if not "!line!"=="" (
        echo !line! | findstr /r "^---" >nul
        echo !line! | findstr /r "dummy" >nul
        if not !errorlevel! == 0 (
            set /a dev_count+=1

            for /f "tokens=1,2 delims=:" %%a in ("!line!") do (
                if not "%%b"=="" (
                    echo [!dev_count!] %%b
                    set "device[!dev_count!]=%%b"
                )
            )
        )
    )
)

:: Add no sound
set /a dev_count+=1
echo [%dev_count%] "No sound"

:: Mic device
set /p mic_choice="Please set No. of Mic device:"
if "%mic_choice%"=="%dev_count%" (
    set mic=
) else (
    set mic=-f dshow -i audio="!device[%mic_choice%]!"
)

:: Mixer device
set /p mixer_choice="Pleaset No. of Sound mixer device:"
if "%mixer_choice%"=="%dev_count%" (
    set mixer=
) else (
    set mixer=-f dshow -i audio="!device[%mixer_choice%]!"
)

:: BGM
echo "Set BGM?:"
echo "1. Use Network stream"
echo "2. Use local media file"
echo "3. No BGM"
set /p bgm_choice="Please select. (1/2/3 default: 3):"
if "%bgm_choice%"=="1" (
    set /p music_playlists="Please input Network stream URL:"
    set music_loops=
) else if "%bgm_choice%"=="2" (
    set /p music_loops="Please input path of local media file:"
) else (
    set music_playlists=
    set music_loops=
)


if "%bgm_choice%"=="1" (
    %music_playlists%=-stream_loop -1 -i "%music_playlists%"
)

if "%bgm_choice%"=="2" (
    %music_loops%=-i "%music_loops%"
)


:: Output options
echo "Please select output option:"
echo "1. Only Live"
echo "2. Only local record"
echo "3. Both Live and record"
set /p choice="Please select. (1/2/3 default: 3):"
if "%choice%"=="1" (
    set record=-f flv "rtmps://a.rtmps.youtube.com:443/live2/%stream_key%"
) else if "%choice%"=="2" (
    set record=-f flv "%video_dir%GODIUS_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%.flv"
) else (
    set record=-f flv "%video_dir%\GODIUS_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%.flv" -f flv "rtmps://a.rtmps.youtube.com:443/live2/%stream_key%"
)

:: Output screen size
set /p screen_size="Display chat screen? (y/n default: n):"
if /i "%screen_size%"=="y" (
    set screen_size=800x480
) else (
    set screen_size=800x600
)

:: Interval seconds of starting FFmpeg
set /p blank_time="Please set interval on seconds (default: 30)"
if "%blank_time%"=="" (
    set blank_time=30
)

timeout /t %blank_time% /nobreak

:: Run FFmpeg
ffmpeg %mic% %mixer% %music_playlists% %music_loops% -framerate 30 -video_size %screen_size% -f gdigrab -i desktop -c:v libx264 %copyright% -preset veryfast -g 60 -b:v 4000k -maxrate 4000k -bufsize 12000k -c:a aac %record%


:: Error hundling
if errorlevel 1 (
    echo "Error, please check ffmpeg config."
    pause
)
