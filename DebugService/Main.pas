unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Buttons, Vcl.ExtCtrls, System.Types, ServiceProcess, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPServer;

type
  TfrmMain = class(TForm)
    pnlTitle: TPanel;
    pnlHeader: TPanel;
    pnlButtons: TPanel;
    bvlDivison: TBevel;
    btnStartService: TBitBtn;
    btnStopService: TBitBtn;
    pnlBottom: TPanel;
    pnlClient: TPanel;
    grbLog: TGroupBox;
    redtLog: TRichEdit;
    procedure btnStartServiceClick(Sender: TObject);
    procedure btnStopServiceClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FServiceControllerManager: TServiceControllerManager;
    procedure StartService;
    procedure StopService;
    procedure Logar(const AText: string);
  public
    { Public declarations }
    procedure AfterConstruction; override;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  ServiceLog;

{$R *.dfm}

{ TfrmMain }

procedure TfrmMain.AfterConstruction;
begin
  inherited;
  FServiceControllerManager := TServiceControllerManager.Create;

  Log.OnTraceDebug := Logar;
  Log.TraceFileName := 'ValterLog.txt';
end;

procedure TfrmMain.btnStartServiceClick(Sender: TObject);
begin
  btnStartService.Enabled := False;
  btnStopService.Enabled := True;
  redtLog.Lines.Clear;

  StartService;
end;

procedure TfrmMain.btnStopServiceClick(Sender: TObject);
begin
  btnStartService.Enabled := True;
  btnStopService.Enabled := False;

  StopService;
end;

procedure TfrmMain.StartService;
begin
  FServiceControllerManager.Start;
end;

procedure TfrmMain.StopService;
begin
  FServiceControllerManager.Stop;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  FServiceControllerManager.Stop;
  FServiceControllerManager.Free;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  lRect: TRectF;
begin
  lRect := TRectF.Create(Screen.WorkAreaRect.TopLeft, Screen.WorkAreaRect.Width,
                         Screen.WorkAreaRect.Height);
  SetBounds(Round(lRect.Left + (lRect.Width - Width) / 2),
            0,
            Width,
            Screen.WorkAreaRect.Height);
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  if (Self.Width < 700) then
  begin
    Self.Width := 700;
    Abort;
  end;
end;

procedure TfrmMain.Logar(const AText: string);
begin
  redtLog.Lines.Add(AText);
end;

end.
