@echo off

rem Thanks to http://stackoverflow.com/questions/7865432/command-line-compile-using-cl-exe
cmd /c ""C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x64 && cl.exe %*"
