@echo off
chcp 1252>NUL          &:: für richtige Umlautdarstellung (mit ANSI-Codierung)
echo Diese Batch-Datei installiert den DW2-Deutsch-Patch.
echo Die zu überschreibenden Dateien und Verzeichnisse werden dabei in ein "Backup"-Verzeichnis gesichert.
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
if not exist ..\Backup\ mkdir ..\Backup\
xcopy /S ..\Galactopedia\ ..\Backup\Galactopedia\
xcopy /S ..\dialog\ ..\Backup\dialog\
xcopy /Y ..\ArmyTemplates.xml ..\Backup\
xcopy /Y ..\Artifacts.xml ..\Backup\
xcopy /Y ..\ColonyEventDefinitions.xml ..\Backup\
xcopy /Y ..\ComponentDefinitions.xml ..\Backup\
xcopy /Y ..\FleetTemplates.xml ..\Backup\
xcopy /Y ..\GameEvents.xml ..\Backup\
xcopy /Y ..\GameEvents_Governments.xml ..\Backup\
xcopy /Y ..\GameText.txt ..\Backup\
xcopy /Y ..\Governments.xml ..\Backup\
xcopy /Y ..\Hints.txt ..\Backup\
xcopy /Y ..\OrbTypes.xml ..\Backup\
xcopy /Y ..\PlanetaryFacilityDefinitions.xml ..\Backup\
xcopy /Y ..\Races.xml ..\Backup\
xcopy /Y ..\ResearchProjectDefinitions.xml ..\Backup\
xcopy /Y ..\Resources.xml ..\Backup\
xcopy /Y ..\ShipHulls*.xml ..\Backup\
xcopy /Y ..\SpaceItemDefinitions.xml ..\Backup\
xcopy /Y ..\TourItems.xml ..\Backup\
xcopy /Y ..\TroopDefinitions.xml ..\Backup\
echo.
::-------------- LÖSCHEN VERZEICHNISSE ---------------
echo Alte Galactopedia und dialog Verzeichnisse werden gelöscht...
if exist ..\Galactopedia\ rmdir /S /Q ..\Galactopedia\
if exist ..\dialog\ rmdir /S /Q ..\dialog\
echo.
::-------------- KOPIEREN DER PATCH-DATEIEN -----------
echo Patch-Dateien werden kopiert...
xcopy /S .\Galactopedia\ ..\Galactopedia\
xcopy /S .\dialog\ ..\dialog\
xcopy /Y .\*.xml ..\
xcopy /Y .\*.txt ..\
echo.
::-------------- ENDE --------------
echo Deutsch-Patch-Dateien kopiert
echo Alte Dateien befinden sich im Backup-Ordner
echo.
pause
exit
::------------- PATCH IM FALSCHEN VERZEICHNIS --------------
:falsch
echo Der Deutsch Patch scheint im falschen Verzeichnis zu sein.
echo.
echo Bitte stelle sicher, dass das Patch-Verzeichnis DW2 im "data"-Ordner des Spieleverzeichnisses ist
echo und starte diese Batch-Datei neu.
echo.
pause
exit