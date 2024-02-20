@echo off
chcp 1252>NUL          &:: für richtige Umlautdarstellung (mit ANSI-Codierung)
echo Diese Batch-Datei installiert den DW2-Deutsch-Patch für den DLC Gizurean und Quameno 1.1.8.7.
echo Die zu überschreibenden Dateien und Verzeichnisse werden dabei in das "BackupQuamGizu1187"-Verzeichnis gesichert.
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
if not exist ..\BackupQuamGizu1187\ mkdir ..\BackupQuamGizu1187\
xcopy /Y ..\Artifacts_Gizurean.xml ..\BackupQuamGizu1187\
xcopy /Y ..\Artifacts_Quameno.xml ..\BackupQuamGizu1187\
xcopy /Y ..\ColonyEventDefinitions_Gizurean.xml ..\BackupQuamGizu1187\
xcopy /Y ..\ColonyEventDefinitions_Quameno.xml ..\BackupQuamGizu1187\
xcopy /Y ..\ComponentDefinitions_Gizurean.xml ..\BackupQuamGizu1187\
xcopy /Y ..\ComponentDefinitions_Quameno.xml ..\BackupQuamGizu1187\
xcopy /Y ..\GameEvents_Cell_Hegemony_Government.xml ..\BackupQuamGizu1187\
xcopy /Y ..\GameEvents_Geniocracy_Government.xml ..\BackupQuamGizu1187\
xcopy /Y ..\GameEvents_Gizurean.xml ..\BackupQuamGizu1187\
xcopy /Y ..\GameEvents_Quameno.xml ..\BackupQuamGizu1187\
xcopy /Y ..\Governments_Gizurean.xml ..\BackupQuamGizu1187\
xcopy /Y ..\Governments_Quameno.xml ..\BackupQuamGizu1187\
xcopy /Y ..\PlanetaryFacilityDefinitions_Gizurean.xml ..\BackupQuamGizu1187\
xcopy /Y ..\PlanetaryFacilityDefinitions_Quameno.xml ..\BackupQuamGizu1187\
xcopy /Y ..\Races_Gizurean.xml ..\BackupQuamGizu1187\
xcopy /Y ..\Races_Quameno.xml ..\BackupQuamGizu1187\
xcopy /Y ..\ResearchProjectDefinitions_Gizurean.xml ..\BackupQuamGizu1187\
xcopy /Y ..\ResearchProjectDefinitions_Quameno.xml ..\BackupQuamGizu1187\
xcopy /Y ..\ShipHulls_Gizurean.xml ..\BackupQuamGizu1187\
xcopy /Y ..\ShipHulls_Quameno.xml ..\BackupQuamGizu1187\
xcopy /Y ..\TroopDefinitions_Gizurean.xml ..\BackupQuamGizu1187\
xcopy /Y ..\TroopDefinitions_Quameno.xml ..\BackupQuamGizu1187\
echo.
::-------------- KOPIEREN DER PATCH-DATEIEN -----------
echo Patch-Dateien werden kopiert...
xcopy /Y .\*.xml ..\
echo.
::-------------- ENDE --------------
echo Deutsch-Patch-IkkuDhay1187-Dateien kopiert
echo Alte Dateien befinden sich im BackupQuamGizu1187-Ordner
echo.
pause
exit
::------------- PATCH IM FALSCHEN VERZEICHNIS --------------
:falsch
echo Der Deutsch Patch scheint im falschen Verzeichnis zu sein.
echo.
echo Bitte stelle sicher, dass das Patch-Verzeichnis "DLC Quameno and Gizurean" im "data"-Ordner des Spieleverzeichnisses ist
echo und starte diese Batch-Datei neu.
echo.
pause
exit