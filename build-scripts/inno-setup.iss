; FILE: build-scripts/inno-setup.iss

[Setup]
; App details
AppName=ETH Hunter
AppVersion=1.0.0
AppPublisher=ROVOID
AppPublisherURL=https://rovoid.ir
AppSupportURL=https://github.com/IMROVOID/ETH-Hunter
AppUpdatesURL=https://github.com/IMROVOID/ETH-Hunter/releases

; Install directory
DefaultDirName={autopf64}\ETH Hunter
DefaultGroupName=ETH Hunter
DisableProgramGroupPage=yes
OutputBaseFilename=ETH-Hunter-v1.0.0-Windows-Setup
PrivilegesRequired=lowest
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

; Icon for the installer itself
SetupIconFile=assets\icons\app.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; This command grabs every file from your Flutter build output and includes it in the installer.
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Start Menu and Desktop shortcuts
Name: "{group}\ETH Hunter"; Filename: "{app}\eth_hunter.exe"; IconFilename: "{app}\app.ico"
Name: "{autodesktop}\ETH Hunter"; Filename: "{app}\eth_hunter.exe"; Tasks: desktopicon; IconFilename: "{app}\app.ico"

[Run]
Filename: "{app}\eth_hunter.exe"; Description: "{cm:LaunchProgram,ETH Hunter}"; Flags: nowait postinstall skipifsilent
