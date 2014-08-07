@echo off
echo 创建文件夹链接

::将工作空间与工程编译结果相连

del /Q "Plugin Console\bin"
mklink /j "Plugin Console\bin" "WorkSpace Host\plugins\Console"

pause >nul