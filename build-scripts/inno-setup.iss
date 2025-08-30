// FILE: build-scripts/inno-setup.iss
// This script uses defines, which are variables passed in from the GitHub Action.

#define AppName "ETH Hunter"
#define AppVersion "{#AppVersion}"         // Passed via Action
#define AppPublisher "ROVOID"
#define AppURL "https://rovoid.ir"
#define AppExeName "eth_hunter.exe"
#define ProjectRoot "{#ProjectRoot}"       // Passed via Action
#define OutputName "{#OutputName}"         // Passed via Action
#define OutputDir "{#OutputDir}"           // Passed via Action

[Setup]
; Basic application details
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL=https://github.com/IMROVOID/ETH-Hunter
AppUpdatesURL=https://github.com/IMROVOID/ETH-Hunter/releases

; Installer wizard style and compression
WizardStyle=modern
SolidCompression=yes
Compression=lzma2

; Allow user to choose between "All Users" (admin) or "Current User" (non-admin)
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog

; Output file settings
OutputBaseFilename={#OutputName}
OutputDir={#OutputDir}
DefaultDirName={autopf64}\{#AppName}
DefaultGroupName={#AppName}

; Installer icon and language selection
SetupIconFile={#ProjectRoot}\assets\icons\app.ico
ShowLanguageDialog=yes

[Languages]
; Provides a dialog for the user to select their language.
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
; Allows the user to select optional tasks during installation.
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked;

[Files]
; Copy all the application files from the build output to the installation directory.
Source: "{#ProjectRoot}\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Copy the icon to the installation directory for use in shortcuts and the uninstaller.
Source: "{#ProjectRoot}\assets\icons\app.ico"; DestDir: "{app}"; DestName: "app.ico"

[Icons]
; Creates the Start Menu entry.
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\app.ico"

; Creates the desktop icon if the user selected the task.
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon; IconFilename: "{app}\app.ico"

; Creates the Quick Launch icon if the user selected the task.
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: quicklaunchicon; IconFilename: "{app}\app.ico"

[Run]
; Gives the user the option to launch the application after installation is complete.
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
