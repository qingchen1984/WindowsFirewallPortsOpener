:: Name:     Windows Firewall Port Opener
:: Author:   Joel-David Wong
:: Revision: November 2016 - initial version

@ECHO OFF
ECHO Windows Firewall Ports Opener Script - OnesAndZeros.sg
ECHO -----------------------------------------------------
GOTO CHECKADMIN

:START
set /p PORT="Enter Port No.: "
ECHO.
SET /A Evaluated=PORT
if %Evaluated% EQU %PORT% (
    IF %PORT% GTR 0 ( 
		GOTO PROTOCOL
	) ELSE ( 
		ECHO Please Enter A Valid Port Number 
		ECHO ----------------------------------------
	)
) ELSE (
    ECHO Please Enter A Valid Port Number
	ECHO ----------------------------------------
)

GOTO START

:PROTOCOL
ECHO For Which Protocol(s)?
ECHO 1. TCP
ECHO 2. UDP
ECHO 3. BOTH
CHOICE /N /C:123 /M "Enter your choice:"%1
IF ERRORLEVEL ==3 GOTO THREE
IF ERRORLEVEL ==2 GOTO TWO
IF ERRORLEVEL ==1 GOTO ONE
GOTO END
:THREE
CALL :RULENAMETCP
CALL :TCP
CALL :RULENAMEUDP
CALL :UDP
GOTO COMPLETED
:TWO
CALL :RULENAMEUDP
CALL :UDP
GOTO COMPLETED
:ONE
CALL :RULENAMETCP
CALL :TCP
GOTO COMPLETED
:END
PAUSE
EXIT /B

:RULENAMETCP
ECHO.
set RULENAME=
set /p "RULENAME=Enter Rule Name for TCP Port %PORT% (Blank for a generic name):"
IF "z%RULENAME%"=="z" ( 
	set RULENAME=Open Port %PORT% - TCP
)
ECHO.
ECHO Rule Name: %RULENAME%
ECHO.
EXIT /B

:RULENAMEUDP
ECHO.
set RULENAME=
set /p "RULENAME=Enter Rule Name for UDP Port %PORT% (Blank for a generic name):"
IF "z%RULENAME%"=="z" ( 
	set RULENAME=Open Port %PORT% - UDP
)
ECHO.
ECHO Rule Name: %RULENAME%
ECHO.
EXIT /B

:TCP
netsh advfirewall firewall show rule name="%RULENAME%" >nul
if not ERRORLEVEL 1 (
    ECHO There is already a rule name %RULENAME%.
) else (
	ECHO Creating "%RULENAME%"
    netsh advfirewall firewall add rule name="%RULENAME%" dir=in action=allow protocol=TCP localport=%PORT%
)
EXIT /B

:UDP
netsh advfirewall firewall show rule name="%RULENAME%" >nul
if not ERRORLEVEL 1 (
    ECHO There is already a rule name "%RULENAME%".
) else (
	ECHO Creating "%RULENAME%"
    netsh advfirewall firewall add rule name="%RULENAME%" dir=in action=allow protocol=UDP localport=%PORT%
)
EXIT /B

:COMPLETED
PAUSE

:CHECKADMIN
net session >nul 2>&1
IF %errorLevel% == 0 (
	GOTO START
) else (
	ECHO.
	Color 0C
	ECHO Please run this script as an Administrator!
)
PAUSE >nul
	