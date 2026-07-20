@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

REM ================= 基础配置 =================
set "ZSTD=zstd\zstd.exe"
set "GAME_EXE=Game.exe"
set "UPDATES_DIR=Updates"
set "MAX_LOOP=20"  REM 防止死循环，最多连续更新20次（足够覆盖绝大多数情况）
set "LOOP_COUNT=0"

REM ================= 核心循环逻辑 =================
:UPDATE_LOOP
REM 限制循环次数，防止异常情况无限循环
set /a LOOP_COUNT+=1
if !LOOP_COUNT! gtr %MAX_LOOP% (
    echo 已达到最大更新次数（%MAX_LOOP%），停止更新
    goto LAUNCH_GAME
)

REM 检查核心依赖
if not exist "%ZSTD%" (
    echo 错误：找不到zstd程序
    pause
    goto END
)
if not exist "%UPDATES_DIR%\" (
    echo 错误：找不到Updates目录
    pause
    goto END
)

REM 1. 找当前最新的旧版本game_X.exe
set "OLD_EXE="
set "CURRENT_VER="
for /f "delims=" %%f in ('dir /b /a-d "%UPDATES_DIR%\game_*.exe" 2^>nul') do (
    set "fn=%%~nf"
    set "ver=!fn:game_=!"
    echo !ver!| findstr /r "^[0-9][0-9]*$" >nul
    if !errorlevel! equ 0 (
        set "CURRENT_VER=!ver!"
        set "OLD_EXE=%UPDATES_DIR%\%%f"
        goto FOUND_OLD
    )
)
:FOUND_OLD
REM 没找到旧版本，说明已经是最新版，直接启动游戏
if "%OLD_EXE%"=="" goto LAUNCH_GAME

REM 2. 找对应补丁patch_X_to_Y.ta
set "PATCH="
set "TARGET_VER="
for /f "delims=" %%f in ('dir /b /a-d "%UPDATES_DIR%\patch_%CURRENT_VER%_to_*.ta" 2^>nul') do (
    set "fn=%%~nf"
    for /f "tokens=1-4 delims=_" %%a in ("!fn!") do (
        if "%%a"=="patch" (
            if "%%c"=="to" (
                if "%%b"=="!CURRENT_VER!" (
                    echo %%d| findstr /r "^[0-9][0-9]*$" >nul
                    if !errorlevel! equ 0 (
                        set "TARGET_VER=%%d"
                        set "PATCH=%UPDATES_DIR%\%%f"
                        goto FOUND_PATCH
                    )
                )
            )
        )
    )
)
:FOUND_PATCH
REM 没找到对应补丁，说明已经是最新版，直接启动游戏
if "%PATCH%"=="" goto LAUNCH_GAME

REM 3. 合并补丁（和你跑通的逻辑完全一致）
set "NEW_EXE=%UPDATES_DIR%\game_%TARGET_VER%.exe"
if exist "%NEW_EXE%" del /f /q "%NEW_EXE%"

echo 正在更新：版本%CURRENT_VER% → %TARGET_VER%（第!LOOP_COUNT!次更新）
"%ZSTD%" -d --long=31 --patch-from="%OLD_EXE%" "%PATCH%" -o "%NEW_EXE%"
if %errorlevel% neq 0 (
    echo 错误：版本%CURRENT_VER%→%TARGET_VER%合并失败，停止更新
    pause
    goto END
)

if not exist "%NEW_EXE%" (
    echo 错误：合并后文件不存在，停止更新
    pause
    goto END
)

REM 4. 部署新版本到根目录
if exist "%GAME_EXE%" move /y "%GAME_EXE%" "%GAME_EXE%.bak" >nul
copy /y "%NEW_EXE%" "%GAME_EXE%" >nul
if not exist "%GAME_EXE%" (
    echo 错误：复制新版本失败，停止更新
    if exist "%GAME_EXE%.bak" move /y "%GAME_EXE%.bak" "%GAME_EXE%" >nul
    pause
    goto END
)

REM 5. 清理合并用的源文件（保留新版本在Updates里，作为下一次更新的旧版本）
del /f /q "%OLD_EXE%"
del /f /q "%PATCH%"
echo 版本%CURRENT_VER%→%TARGET_VER%更新完成！
echo -------------------------

REM 6. 关键：回到循环开头，继续扫描下一个补丁
goto UPDATE_LOOP

REM ================= 启动游戏 =================
:LAUNCH_GAME
if exist "%GAME_EXE%" (
    echo 游戏已是最新版，启动中...
    ping -n 1 127.0.0.1 >nul
    start "" "%GAME_EXE%"
)

:END
endlocal
exit