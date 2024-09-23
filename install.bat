@echo off
chcp 65001
setlocal enabledelayedexpansion

:: ステップ 1: Chocolateyがインストールされているか確認
choco -v >nul 2>&1
if %errorlevel% neq 0 (
    echo Chocolateyがインストールされていません。インストールを開始します...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
) else (
    echo Chocolateyは既にインストールされています。
)
pause

:: ステップ 2: FFmpegがインストールされているか確認
ffmpeg -version >nul 2>&1
if %errorlevel% neq 0 (
    echo FFmpegがインストールされていません。インストールを開始します...
    choco install ffmpeg -y
) else (
    echo FFmpegは既にインストールされています。
)
pause