; FILE: setup.iss

#define MyAppName "ETH-Hunter"
#define MyAppPublisher "IMROVOID"
#define MyAppURL "https://github.com/IMROVOID/ETH-Hunter"
#define MyAppExeName "eth_hunter.exe"

[Setup]
AppId={{YOUR-APP-GUID-HERE}}  ; Replace with a unique GUID (generate via Tools > Generate GUID in Inno Setup Compiler)
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={code:GetAppDir}
DisableProgramGroupPage=auto
OutputDir=.
OutputBaseFilename=ETH-Hunter-{#MyAppVersion}-Windows-Installer
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "armenian"; MessagesFile: "compiler:Languages\Armenian.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "bulgarian"; MessagesFile: "compiler:Languages\Bulgarian.isl"
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
Name: "corsican"; MessagesFile: "compiler:Languages\Corsican.isl"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "hungarian"; MessagesFile: "compiler:Languages\Hungarian.isl"
Name: "icelandic"; MessagesFile: "compiler:Languages\Icelandic.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "nepali"; MessagesFile: "compiler:Languages\Nepali.isl"
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "scotsgaelic"; MessagesFile: "compiler:Languages\ScotsGaelic.isl"
Name: "serbiancyrillic"; MessagesFile: "compiler:Languages\SerbianCyrillic.isl"
Name: "serbianlatin"; MessagesFile: "compiler:Languages\SerbianLatin.isl"
Name: "slovak"; MessagesFile: "compiler:Languages\Slovak.isl"
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Tasks]
Name: desktopicon; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: startmenu; Description: "Create Start Menu shortcuts"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{code:GetProgramsDir}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: startmenu
Name: "{code:GetDesktopDir}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

[Code]
var
  UserModePage: TInputOptionWizardPage;

procedure InitializeWizard;
begin
  UserModePage := CreateInputOptionPage(wpWelcome,
    'Installation Mode', 'Select the installation scope.',
    'Please choose whether to install for the current user only or for all users of this computer.',
    True, False);
  UserModePage.Add('Just me (current user only - recommended)');
  UserModePage.Add('All users (requires administrator privileges)');
  if IsAdminInstallMode then
    UserModePage.Values[1] := True
  else
    UserModePage.Values[0] := True;
end;

function ShouldSkipPage(CurPageID: Integer): Boolean;
begin
  Result := (CurPageID = UserModePage.ID) and
    (ExpandConstant('{param:allusers}') <> '') or (ExpandConstant('{param:justme}') <> '');
end;

function GetIsAllUsers: Boolean;
begin
  if ExpandConstant('{param:allusers}') <> '' then
    Result := True
  else if ExpandConstant('{param:justme}') <> '' then
    Result := False
  else
    Result := UserModePage.Values[1];
end;

function GetAppDir(Param: String): String;
begin
  if GetIsAllUsers then
    Result := ExpandConstant('{commonpf}') + '\{#MyAppName}'
  else
    Result := ExpandConstant('{userpf}') + '\{#MyAppName}';
end;

function GetProgramsDir(Param: String): String;
begin
  if GetIsAllUsers then
    Result := ExpandConstant('{commonprograms}')
  else
    Result := ExpandConstant('{userprograms}');
end;

function GetDesktopDir(Param: String): String;
begin
  if GetIsAllUsers then
    Result := ExpandConstant('{commondesktop}')
  else
    Result := ExpandConstant('{userdesktop}');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Params: String;
  ErrorCode: Integer;
begin
  Result := True;
  if CurPageID = UserModePage.ID then begin
    if GetIsAllUsers and not IsAdminInstallMode then begin
      Params := '/allusers';
      ShellExec('runas', ExpandConstant('{srcexe}'), Params, '', SW_SHOW, ewNoWait, ErrorCode);
      Result := False;
    end;
  end;
end;
