@echo off
chcp 1252>NUL          &:: für richtige Umlautdarstellung (mit ANSI-Codierung)
echo Diese Batch-Datei installiert den DW2-Deutsch-Patch für den DLC Ikkuro und DHayut 1.2.0.4.
echo Die zu überschreibenden Dateien und Verzeichnisse werden dabei in das "BackupIkkuDhay1204"-Verzeichnis gesichert.
echo (Abbruch mit Strg-C)
echo.
pause
echo.
::----------- TEST OB RICHTIGES VERZEICHNIS -------------
echo Teste, ob Deutsch-Patch im richtigen Verzeichnis ausgeführt wird...
if not exist "..\Galactopedia\" goto falsch
echo Der Patch scheint im richtigen Verzeichnis zu sein.
echo.
::----------- SICHERUNG ------------
echo Sichere vorige Dateien...
if not exist ..\BackupIkkuDhay1204\ mkdir ..\BackupIkkuDhay1204\
xcopy /Y ..\Artifacts_Dhayut.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\Artifacts_Ikkuro.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\ColonyEventDefinitions_Dhayut.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\ColonyEventDefinitions_Ikkuro.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\ComponentDefinitions_Dhayut.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\ComponentDefinitions_Ikkuro.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\GameEvents_Dhayut.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\GameEvents_HarmoniousUtopia_Government.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\GameEvents_Ikkuro.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\GameEvents_Ikkuro_RaceEvents.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\GameEvents_SurveillanceOligarchy_Government.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\Governments_Dhayut.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\Governments_Ikkuro.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\PlanetaryFacilityDefinitions_Dhayut.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\PlanetaryFacilityDefinitions_Ikkuro.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\Races_Dhayut.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\Races_Ikkuro.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\ResearchProjectDefinitions_Dhayut.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\ResearchProjectDefinitions_Ikkuro.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\ShipHulls_Dhayut.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\ShipHulls_Ikkuro.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\TroopDefinitions_Dhayut.xml ..\BackupIkkuDhay1204\
xcopy /Y ..\TroopDefinitions_Ikkuro.xml ..\BackupIkkuDhay1204\
echo.
::-------------- KOPIEREN DER PATCH-DATEIEN -----------
echo Patch-Dateien werden kopiert...
xcopy /Y .\*.xml ..\
echo.
::-------------- ENDE --------------
echo Deutsch-Patch-IkkuDhay1187-Dateien kopiert
echo Alte Dateien befinden sich im BackupIkkuDhay1204-Ordner
echo.
pause
exit
::------------- PATCH IM FALSCHEN VERZEICHNIS --------------
:falsch
echo Der Deutsch Patch scheint im falschen Verzeichnis zu sein.
echo.
echo Bitte stelle sicher, dass das Patch-Verzeichnis "DLC Ikkuro and Dhayut" im "data"-Ordner des Spieleverzeichnisses ist
echo und starte diese Batch-Datei neu.
echo.
pause
exit