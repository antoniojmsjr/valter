unit ServiceCustom;

interface

uses
  System.Classes, Vcl.ExtCtrls;

type
  TOnlog = reference to procedure(const Message: string);

  TServiceControllerCustom = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    procedure Start; virtual; abstract;
    procedure Stop; virtual; abstract;
  end;

  TServiceProcessCustom = class
  private
    { private declarations }
  protected
    { protected declarations }
    procedure Log(const pMessage: string);
  public
    { public declarations }
    procedure Start; virtual; Abstract;
    procedure Stop; virtual; Abstract;
  end;

  TServiceProcessTimerCustom = class(TServiceProcessCustom)
  private
    { private declarations }
    FTimerExecute: TTimer;
    procedure SetTimerInterval(const Value: Integer);
    function GetTimerInterval: Integer;
    procedure OnTimerEvent(Sender: TObject);
    procedure OnTerminateEvent(Sender: TObject);
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;
    procedure Execute; virtual; Abstract;
    property TimerInterval: Integer read GetTimerInterval write SetTimerInterval;
  end;

implementation

uses
  System.SysUtils, ServiceLog;

{$REGION 'TServiceProcessCustom'}

procedure TServiceProcessCustom.Log(const pMessage: string);
begin
  ServiceLog.Log.Trace(pMessage);
end;

{$ENDREGION}

{$REGION 'TServiceProcessTimerCustom'}

constructor TServiceProcessTimerCustom.Create;
begin
  FTimerExecute := TTimer.Create(nil);
  FTimerExecute.Interval := 5000; //5sg;
  FTimerExecute.OnTimer := OnTimerEvent;
  FTimerExecute.Enabled := False;
end;

destructor TServiceProcessTimerCustom.Destroy;
begin
  FTimerExecute.Enabled := False;
  FTimerExecute.Free;
  inherited Destroy;
end;

function TServiceProcessTimerCustom.GetTimerInterval: Integer;
begin
  Result := FTimerExecute.Interval;
end;

procedure TServiceProcessTimerCustom.SetTimerInterval(const Value: Integer);
begin
  if (Value < 1) then //1sg
    FTimerExecute.Interval := 1000
  else
    FTimerExecute.Interval := (Value * 1000);
end;

procedure TServiceProcessTimerCustom.OnTerminateEvent(Sender: TObject);
var
  lThreadException: Exception;
begin
  //ATIVA O TIMER
  FTimerExecute.Enabled := True;

  //THREAD GEROU EXCEÇÃO
  if (Sender is TThread) then
    if Assigned(TThread(Sender).FatalException) then
    begin
      lThreadException := Exception(TThread(Sender).FatalException);

      Log(lThreadException.Message);
    end;
end;

procedure TServiceProcessTimerCustom.OnTimerEvent(Sender: TObject);
var
  lThreadExecute: TThread;
begin
  //DESATIVA TIMER
  FTimerExecute.Enabled := False;

  lThreadExecute := TThread.CreateAnonymousThread(procedure
  begin
    Execute;
  end
  );
  lThreadExecute.FreeOnTerminate := True;
  lThreadExecute.OnTerminate := OnTerminateEvent;

  lThreadExecute.Start;
end;

procedure TServiceProcessTimerCustom.Start;
begin
  FTimerExecute.Enabled := True;
end;

procedure TServiceProcessTimerCustom.Stop;
begin
  FTimerExecute.Enabled := False;
end;

{$ENDREGION}

end.
