@echo off
setlocal

if exist *.bin del *.bin
if exist *.lst del *.lst
if exist *.prn del *.prn
if exist *.hex del *.hex
if exist *.rel del *.rel
if exist *.sym del *.sym

if exist ..\..\..\Binary\Apps\tbasic.com del ..\..\..\Binary\Apps\tbasic.com
