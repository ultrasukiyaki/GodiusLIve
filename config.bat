@echo off
chcp 65001
setlocal enabledelayedexpansion

set myDir=%~dp0

if "%video_dir%"=="" (
    set /p video_dir=録画ディレクトリを入力してください。最後は\で終わらせてください。:
)

if "%stream_key%"=="" (
    set /p stream_key=YouTubeストリームキーを入力してください。:
)

echo video_dir=%video_dir%> %myDir%\config.txt
echo stream_key=%stream_key%>> %myDir%\config.txt

echo 設定を保存しました。
pause