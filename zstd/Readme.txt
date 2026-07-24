复制到Shell中使用，对比Game_boxed.exe和Game_49.exe，生成相差的patch_49_to_50.ta。
F:\Github\Pokemon-Chasm\zstd\zstd.exe --patch-from=Game_49.exe Game_boxed.exe -o patch_49_to_50.ta -19 --long=31

双击Game Update.bat，将Updates中的旧版本和Patch生成新版本的文件。
会自动运行20次自动更新，自动更新完成后会自动启动游戏。