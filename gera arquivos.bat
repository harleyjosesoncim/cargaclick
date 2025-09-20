@echo off
setlocal

REM Caminho da pasta raiz do projeto
set "PROJETO=C:\Users\User\Documents\cargaclick"
set "SRC=%PROJETO%\src"

REM Cria a pasta src se não existir
if not exist "%SRC%" mkdir "%SRC%"

REM Arquivos a garantir
set arquivos=App.js index.css App.css reportWebVitals.js

REM Cria cada arquivo vazio se não existir
for %%F in (%arquivos%) do (
    if not exist "%SRC%\%%F" (
        type nul > "%SRC%\%%F"
        echo Criado: %%F
    ) else (
        echo Já existe: %%F
    )
)

echo ----------------------------------
echo Arquivos verificados/criados na pasta: %SRC%
pause
