unit ServiceProcess;

interface

uses
  ServiceCustom;

type
  TServiceProcessStep1 = class;
  TServiceProcessStep2 = class;

  TServiceControllerManager = class(TServiceControllerCustom)
  private
    { private declarations }
    FServiceProcessStep1: TServiceProcessStep1;
    FServiceProcessStep2: TServiceProcessStep2;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;
  end;

  TServiceProcessStep1 = class(TServiceProcessCustom)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    procedure Execute; override;
  end;

  TServiceProcessStep2 = class(TServiceProcessCustom)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    procedure Execute; override;
  end;

implementation

uses
  System.JSON, REST.Json, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, REST.JSon.Types;

{ TServiceControllerManager }

constructor TServiceControllerManager.Create;
begin
  FServiceProcessStep1 := TServiceProcessStep1.Create;
  FServiceProcessStep2 := TServiceProcessStep2.Create;
end;

destructor TServiceControllerManager.Destroy;
begin
  FServiceProcessStep1.Free;
  FServiceProcessStep2.Free;

  inherited Destroy;
end;

procedure TServiceControllerManager.Start;
begin
  FServiceProcessStep1.TimerInterval := 3; //3 SEGUNDOS
  FServiceProcessStep1.Start;
  FServiceProcessStep1.OnLog := Self.OnLog;

  FServiceProcessStep2.TimerInterval := 5; //5 SEGUNDOS
  FServiceProcessStep2.Start;
  FServiceProcessStep2.OnLog := Self.OnLog;
end;

procedure TServiceControllerManager.Stop;
begin
  FServiceProcessStep1.Stop;
  FServiceProcessStep2.Stop;
end;

{ TServiceProcessStep1 }

//EXEMPLO DE CONSUMO API GET IP
procedure TServiceProcessStep1.Execute;
var
  lHttpRequest: TNetHTTPRequest;
  lHttpClient: TNetHTTPClient;
  lIHTTPResponse: IHTTPResponse;
  lTexto: string;
begin
  Log('EXECUTANDO: TServiceProcessStep1');

  lHttpRequest := nil;
  lHttpClient := nil;
  try
    lHttpClient := TNetHTTPClient.Create(nil);
    lHttpClient.SecureProtocols := [];
    lHttpClient.SecureProtocols := [THTTPSecureProtocol.TLS1,
                                    THTTPSecureProtocol.TLS11,
                                    THTTPSecureProtocol.TLS12];
    lHttpRequest := TNetHTTPRequest.Create(nil);
    lHttpRequest.Client := lHttpClient;

    lHttpRequest.Client.Accept := 'application/json';
    lIHTTPResponse := lHttpRequest.Get('https://api.ipgeolocation.io/getip');

    if (lIHTTPResponse.StatusCode = 200) then
    begin
      lTexto := lIHTTPResponse.ContentAsString;

      Log(lTexto);
    end;

    Log('');
  finally
    lHttpRequest.Free;
    lHttpClient.Free;
  end;
end;

{ TServiceProcessStep2 }

//EXEMPLO DE CONSUMO API IBGE
procedure TServiceProcessStep2.Execute;
var
  lHttpRequest: TNetHTTPRequest;
  lHttpClient: TNetHTTPClient;
  lIHTTPResponse: IHTTPResponse;
  lTexto: string;
begin
  Log('EXECUTANDO: TServiceProcessStep2');

  lHttpRequest := nil;
  lHttpClient := nil;
  try
    lHttpClient := TNetHTTPClient.Create(nil);
    lHttpClient.SecureProtocols := [];
    lHttpClient.SecureProtocols := [THTTPSecureProtocol.TLS1,
                                    THTTPSecureProtocol.TLS11,
                                    THTTPSecureProtocol.TLS12];
    lHttpRequest := TNetHTTPRequest.Create(nil);
    lHttpRequest.Client := lHttpClient;

    lHttpRequest.Client.Accept := 'application/json';
    lIHTTPResponse := lHttpRequest.Get('https://servicodados.ibge.gov.br/api/v1/localidades/distritos/160030312');

    if (lIHTTPResponse.StatusCode = 200) then
    begin
      lTexto := lIHTTPResponse.ContentAsString;

      Log(lTexto);
    end;

    Log('');
  finally
    lHttpRequest.Free;
    lHttpClient.Free;
  end;
end;

end.
