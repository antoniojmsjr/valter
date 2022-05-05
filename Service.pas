unit Service;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, ServiceProcess;

type
  TsrvValter = class(TService)
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
  private
    { Private declarations }
    FServiceControllerManager: TServiceControllerManager;
    procedure Logar(const pMessage: string);
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  srvValter: TsrvValter;

implementation

uses
  System.Win.Registry, ServiceLog;

{$R *.dfm}

procedure SetDescriptionServiceApplication(const pNameService: string;
  const pDescriptionService: string);
var
  lReg: TRegistry;
begin
  lReg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    lReg.RootKey := HKEY_LOCAL_MACHINE;
    if lReg.OpenKey('\SYSTEM\CurrentControlSet\Services\' + pNameService, False) then
    begin
      lReg.WriteString('Description', pDescriptionService);
      lReg.CloseKey;
    end;
  finally
    lReg.Free;
  end;
end;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  srvValter.Controller(CtrlCode);
end;

function TsrvValter.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TsrvValter.Logar(const pMessage: string);
begin
  LogMessage(pMessage, EVENTLOG_INFORMATION_TYPE, 0, 10500);


end;

procedure TsrvValter.ServiceAfterInstall(Sender: TService);
begin
  SetDescriptionServiceApplication(Self.Name, 'Serviço de Processamento Valter.');
end;

procedure TsrvValter.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  Continued := True;
  ReportStatus;
  Logar('CONTINUE_SERVICE');

  FServiceControllerManager.Start;
end;

procedure TsrvValter.ServiceCreate(Sender: TObject);
begin
  FServiceControllerManager := TServiceControllerManager.Create;

  Log.OnTraceDebug := Logar;
  Log.TraceFileName := 'ValterLog.txt';
end;

procedure TsrvValter.ServiceDestroy(Sender: TObject);
begin
  FServiceControllerManager.Stop;
  FServiceControllerManager.Free;
end;

procedure TsrvValter.ServicePause(Sender: TService; var Paused: Boolean);
begin
  Paused := True;
  ReportStatus;
  Logar('PAUSE_SERVICE');

  FServiceControllerManager.Stop;
end;

procedure TsrvValter.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Started := True;
  ReportStatus;
  Logar('START_SERVICE');

  FServiceControllerManager.Start;
end;

procedure TsrvValter.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  Stopped := True;
  ReportStatus;
  Logar('STOP_SERVICE');

  FServiceControllerManager.Stop;
end;

end.
