@echo off
setlocal enabledelayedexpansion

REM Caminhos base
set "ROOT=C:\Users\User\Documents\cargaclick"
set "SRC=%ROOT%\src"
set "PUBLIC=%ROOT%\public"

REM Cria as pastas se não existirem
if not exist "%SRC%" mkdir "%SRC%"
if not exist "%PUBLIC%" mkdir "%PUBLIC%"

REM 1. index.js
(
echo import React from 'react';
echo import ReactDOM from 'react-dom/client';
echo ^'./index.css^';
echo import App from './App';
echo import reportWebVitals from './reportWebVitals';
echo.
echo const root = ReactDOM.createRoot(document.getElementById('root'));
