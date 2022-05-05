unit ServiceLog;

interface

uses
  System.SyncObjs, System.IOUtils;

type
  OnTraceDebugEvent = procedure(const AText: string) of object;

  TServiceLog = class
  private class var
    { private var declarations }
    FSingletonLock: TCriticalSection;
    FSingleton: TServiceLog;
    class constructor Create;
    class destructor Destroy;
    class function GetSingleton: TServiceLog; static;
  private
    { private declarations }
    FTraceFileSize: Integer;
    FOnTraceDebug: OnTraceDebugEvent;
    FTraceFileName: string;
    procedure SetTraceFileName(const Value: string);
    procedure SetTraceFileSize(const Value: Integer);
    function GetTraceFileSize: Integer;
    procedure DoTraceLogFile(const pText: string);
    procedure DoTraceDebug(const pText: string);
  protected
    { protected declarations }
  public
    { public declarations }
    procedure Trace(const pMessage: string);
    property OnTraceDebug: OnTraceDebugEvent read FOnTraceDebug write FOnTraceDebug;
    property TraceFileName: string read FTraceFileName write SetTraceFileName;
    property TraceFileSize: Integer read GetTraceFileSize write SetTraceFileSize Default 4096;
  end;

function Log: TServiceLog; inline;

implementation

uses
  System.SysUtils, System.Threading, System.Classes, WinApi.Windows;

function Log: TServiceLog; inline;
begin
  Result := TServiceLog.GetSingleton;
end;

{$REGION 'TServiceLog'}

class constructor TServiceLog.Create;
begin
  FSingletonLock := TCriticalSection.Create;
  FSingleton := nil;
end;

class destructor TServiceLog.Destroy;
begin
  if (FSingleton <> nil) then
  begin
    FSingleton.Free;
    FSingleton := nil;
  end;
  FSingletonLock.Free;
end;

procedure TServiceLog.DoTraceDebug(const pText: string);
begin
  if Assigned(FOnTraceDebug) then
    FOnTraceDebug(pText);
end;

procedure TServiceLog.DoTraceLogFile(const pText: string);
var
  lLogPath: string;
  lLogFile: string;
  lStreamWriter: TStreamWriter;

  function FileSize(const pFileName: String): Int64;
  var
    lWin32FileAttribute: TWin32FileAttributeData;
  begin
    Result := -1;

    if not GetFileAttributesEx(PWideChar(pFilename), GetFileExInfoStandard, @lWin32FileAttribute) then
      Exit;

    Result := Int64(lWin32FileAttribute.nFileSizeLow) or
              Int64(lWin32FileAttribute.nFileSizeHigh shl 32);
  end;

begin
  if (FTraceFileName.Trim.IsEmpty) then
    Exit;

  lLogPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  lLogPath := Format('%s%s', [lLogPath, 'Log\']);

  if not TDirectory.Exists(lLogPath) then
    TDirectory.CreateDirectory(lLogPath);

  lLogFile := Format('%s%s.trace', [lLogPath, FTraceFileName]);

  //CRIA UM BACKUP DO ARQUIVO
  if TFile.Exists(lLogFile) then
    if (FileSize(lLogFile) > TraceFileSize) then
      RenameFile(lLogFile, Format('%s%s[%s]', [lLogPath, FTraceFileName, FormatDateTime('ddmmyyyy-hhmmss.zzz', Now())]));

  //ESCREVE NO ARQUIVO
  lStreamWriter := TStreamWriter.Create(lLogFile, True, TEncoding.Default);
  try
    lStreamWriter.WriteLine(pText);
  finally
    lStreamWriter.Free;
  end;
end;

class function TServiceLog.GetSingleton: TServiceLog;
begin
  if (FSingleton = nil) then
  begin
    FSingletonLock.Enter;
    try
      if FSingleton = nil then
      begin
        FSingleton := TServiceLog.Create;
      end;
    finally
      FSingletonLock.Leave;
    end;
  end;
  Result := FSingleton;
end;

procedure TServiceLog.SetTraceFileName(const Value: string);
begin
  FTraceFileName := ChangeFileExt(Value, EmptyStr);
end;

function TServiceLog.GettraceFileSize: Integer;
begin
  if (FTraceFileSize <= 0) then
    FTraceFileSize := 4096;
  Result := (FTraceFileSize * 1024);
end;

procedure TServiceLog.SetTraceFileSize(const Value: Integer);
begin
  FTraceFileSize := Value;
end;

procedure TServiceLog.Trace(const pMessage: string);
begin
  //DEBUG
  TTask.Run(
    procedure
    begin
      TThread.Synchronize(nil,
      procedure
      var
        lMsg: string;
      begin
        lMsg := Format('%s=%s', [FormatDateTime('dd/mm/yyyy hh:nn:ss', now), pMessage]);
        DoTraceDebug(lMsg);
      end);
    end);

  //FILE
  TTask.Run(
    procedure
    begin
      TThread.Synchronize(nil,
      procedure
      var
        lMsg: string;
      begin
        lMsg := Format('%s=%s', [FormatDateTime('dd/mm/yyyy hh:nn:ss', now), pMessage]);
        DoTraceLogFile(lMsg);
      end);
    end);
end;

{$ENDREGION}

end.
