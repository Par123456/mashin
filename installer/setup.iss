#ifndef AppBuildDir
  #define AppBuildDir "..\build\windows\x64\runner\Release"
#endif

#define MyAppName "ماشین‌حساب خطرناک"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "parsa"
#define MyAppExeName "khatarnak_calculator.exe"

[Setup]
AppId=6C6E7E2B-8B0B-4C0A-9C0E-6B0C7B7F1234
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\KhatarnakCalculator
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=Output
OutputBaseFilename=khatarnak-calculator-setup
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64 x86
ArchitecturesInstallIn64BitMode=x64
MinVersion=6.1
PrivilegesRequired=lowest
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#AppBuildDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "ایجاد آیکن روی دسکتاپ"; GroupDescription: "میانبره‌ها:"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "اجرای برنامه"; Flags: nowait postinstall skipifsilent
