@echo off
setlocal
call "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 exit /b %errorlevel%
for /f "delims=" %%i in ('uv run --isolated --with pybind11 python -m pybind11 --cmakedir') do set "PYBIND11_DIR=%%i"
pushd "%~dp0"
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -Dpybind11_DIR="%PYBIND11_DIR%"
if errorlevel 1 exit /b %errorlevel%
cmake --build build --target recast_native
if errorlevel 1 exit /b %errorlevel%
popd
