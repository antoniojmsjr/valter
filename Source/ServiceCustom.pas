unit ServiceCustom;

interface

uses
  System.Classes, Vcl.ExtCtrls;

type
  TOnlog = reference to procedure(const Message: string);

  TServiceControllerCustom = class
  private
    { private declarations }
    FOnLog: TOnlog;
  protected
    { protected declarations }
  public
    { public declarations }
    procedure Start; virtual; abstract;
    procedure Stop; virtual; abstract;
    property OnLog: TOnlog read FOnLog write FOnLog;
  end;

  TServiceProcessCustom = class
  private
    { private declarations }
    FTimerExecute: TTimer;
    FOnLog: TOnlog;
    procedure SetTimerInterval(const Value: Integer);
    function GetTimerInterval: Integer;
    procedure OnTimerEvent(Sender: TObject);
    procedure OnTerminateEvent(Sender: TObject);
  protected
    { protected declarations }
    procedure Log(const pMessage: string);
  public
    { public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    procedure Execute; virtual; Abstract;
    property TimerInterval: Integer read GetTimerInterval write SetTimerInterval;
    property OnLog: TOnlog read FOnLog write FOnLog;
  end;

implementation

uses
  System.SysUtils;

{$REGION 'TServiceProcessCustom'}

constructor TServiceProcessCustom.Create;
begin
  FTimerExecute := TTimer.Create(nil);
  FTimerExecute.Interval := 5000; //5sg;
  FTimerExecute.OnTimer := OnTimerEvent;
  FTimerExecute.Enabled := False;
end;

destructor TServiceProcessCustom.Destroy;
begin
  FTimerExecute.Enabled := False;
  FTimerExecute.Free;
  inherited Destroy;
end;

function TServiceProcessCustom.GetTimerInterval: Integer;
begin
  Result := FTimerExecute.Interval;
end;

procedure TServiceProcessCustom.Log(const pMessage: string);
begin
  if Assigned(FOnLog) then
    FOnLog(pMessage);
end;

procedure TServiceProcessCustom.SetTimerInterval(const Value: Integer);
begin
  if (Value < 1) then //1sg
    FTimerExecute.Interval := 1000
  else
    FTimerExecute.Interval := (Value * 1000);
end;

procedure TServiceProcessCustom.OnTerminateEvent(Sender: TObject);
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

      //lThreadException.Message;
    end;
end;

procedure TServiceProcessCustom.OnTimerEvent(Sender: TObject);
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

procedure TServiceProcessCustom.Start;
begin
  FTimerExecute.Enabled := True;
end;

procedure TServiceProcessCustom.Stop;
begin
  FTimerExecute.Enabled := False;
end;

{$ENDREGION}

end.
