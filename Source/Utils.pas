unit Utils;

interface

uses
  Winapi.Windows, Winapi.ShellAPI, Winapi.TlHelp32;

function GetUserToken: NativeUInt;
function ExecApp(const pCommandLine: PWideChar): Boolean;

implementation

uses
  System.Types;

function WTSQueryUserToken(SessionId: ULONG; var phToken: THandle): BOOL; stdcall; external 'wtsapi32.dll';
function IsUserAnAdmin: BOOL; stdcall; external 'shell32.dll' name 'IsUserAnAdmin';

function IsUserAdmin: Boolean;
begin
  Result := IsUserAnAdmin;
  //SetLastError(ERROR_ACCESS_DENIED);
end;

function GetUserToken: NativeUInt;
var
  lSessionID: DWORD;
begin
  lSessionID := WtsGetActiveConsoleSessionID;
  WTSQueryUserToken(WtsGetActiveConsoleSessionID, Result);
end;

function ExecAppProcessAsUser(const pCommandLine: PWideChar; const pUserToken: NativeUInt): Boolean;
var
  lpCommandLine: string;
  lpStartupInfo: TStartupInfo;
  lpProcessInformation: TProcessInformation;
begin
  Result := False;

  if (pUserToken = 0) then
    Exit;

  lpCommandLine := (#34 + pCommandLine + #34);
  UniqueString(lpCommandLine);
  FillChar(lpStartupInfo, SizeOf(lpStartupInfo), 0);
  lpStartupInfo.cb := SizeOf(lpStartupInfo);

  Result := CreateProcessAsUser(pUserToken,
                                nil,
                                PWideChar(lpCommandLine),
                                nil,
                                nil,
                                False,
                                CREATE_NEW_CONSOLE,
                                nil,
                                nil,
                                lpStartupInfo,
                                lpProcessInformation);
end;

function ExecApp(const pCommandLine: PWideChar): Boolean;
var
  lUserToken: NativeUInt;
  lSessionID: DWORD;
begin
  Result := False;

  lSessionID := WtsGetActiveConsoleSessionID;
  if WTSQueryUserToken(lSessionID, lUserToken) then
  begin
    Result := ExecAppProcessAsUser(pCommandLine, lUserToken);
    CloseHandle(lUserToken);
  end;
end;

end.
