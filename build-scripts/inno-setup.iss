// FILE: build-scripts/inno-setup.iss

// Define a variable for the project's root directory.
// The value for ProjectRoot will be passed in from the GitHub Actions command line.
#define ProjectRoot "."

[Setup]
; App details
AppName=ETH Hunter
AppVersion=1.0.0 ; This is a placeholder, will be overwritten by the /DAppVersion flag
AppPublisher=ROVOID
AppPublisherURL=https://rovoid.ir
AppSupportURL=https://github.com/IMROVOID/ETH-Hunter
AppUpdatesURL=https://github.com/IMROVOID/ETH-Hunter/releases

; Install directory
DefaultDirName={autopf64}\ETH Hunter
DefaultGroupName=ETH Hunter
DisableProgramGroupPage=yes
OutputBaseFilename=ETH-Hunter-v1.0.0-Windows-Setup ; Placeholder, overwritten by /F flag
PrivilegesRequired=lowest
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

; Icon for the installer itself, now using the robust, absolute path
SetupIconFile="{#ProjectRoot}\assets\icons\app.ico"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; This command now uses the robust, absolute path to find the application files
Source: "{#ProjectRoot}\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; The icon for shortcuts is copied into the {app} dir, so this path is correct.
Name: "{group}\ETH Hunter"; Filename: "{app}\eth_hunter.exe"; IconFilename: "{app}\app.ico"
Name: "{autodesktop}\ETH Hunter"; Filename: "{app}\eth_hunter.exe"; Tasks: desktopicon; IconFilename: "{app}\app.ico"

[Run]
Filename: "{app}\eth_hunter.exe"; Description: "{cm:LaunchProgram,ETH Hunter}"; Flags: nowait postinstall skipifsilent
