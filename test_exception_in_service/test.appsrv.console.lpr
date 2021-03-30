program test.appsrv.console;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp,
  mormot.core.base,          // sllInfo, sllServer
  mormot.core.log,           // TSynLog
  mormot.core.os,            // ConsoleWaitForEnterKey
  mormot.core.interfaces,    // TInterfaceFactory
  mormot.orm.core,           // TOrmModel (was TSQLModel)
  mormot.soa.core,           // sicShared, TServiceFactory
  mormot.rest.server,        // TRestServerRoutingRest - просто чтобы посмотреть ошибку
  mormot.rest.memserver,     // TRestServerFullMemory (was TSQLRestServerFullMemory)
  mormot.rest.http.server,   // TRestHttpServer (was TSQLHttpServer)
  test.appsrv.core
  ;

type
  {TestAppSrv}
  TestAppSrv = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

{TMAppSrv}
procedure TestAppSrv.DoRun;
var
  aModel:       TOrmModel;                   // was TSQLModel
  aRestSrvDB:   TRestServerFullMemory;       // was TSQLRestServerFullMemory
  aRestSrvHttp: TRestHttpServer;             // was TSQLHttpServer
begin
  // If you uncomment the line below, then when there is an exception in the service method
  // (test.appsrv.core / TUsrService.GetUsr),
  // and it will be handled, then another exception (EAccessViolation) will occur
  // in the astrings.inc / Procedure fpc_AnsiStr_Assign / Line 180 (if DestS=S2 then...)
  ///TSynLog.Family.Level := LOG_STACKTRACE + [sllInfo, sllServer];

  aModel := TOrmModel.Create([], 'root');
  try
    aRestSrvDB := TRestServerFullMemory.Create(aModel);
    try
      TInterfaceFactory.RegisterInterfaces([TypeInfo(IUsrService)]);
      aRestSrvDB.ServiceDefine(TUsrService, [IUsrService]{, sicShared});

      aRestSrvHttp := TRestHttpServer.Create('8888', [aRestSrvDB]);
      try
        aRestSrvHttp.AccessControlAllowOrigin := '*'; // allow cross-site AJAX queries

        writeln('Background server is running'#10);
        writeln('test:');
        writeln('curl --header "Content-Type: application/json" --request POST --data ''{"aUsrID":"12345"}'' http://localhost:8888/root/UsrService/GetUsr');
        write('Press [Enter] to close the server.');

        ConsoleWaitForEnterKey;
      finally
        aRestSrvHttp.Free;
      end;
    finally
      aRestSrvDB.Free;
    end;
  finally
    aModel.Free;
  end;

  // stop program loop
  Terminate;
end;

constructor TestAppSrv.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException := True;
end;

destructor TestAppSrv.Destroy;
begin
  inherited Destroy;
end;

var
  Application: TestAppSrv;
begin
  Application := TestAppSrv.Create(nil);
  Application.Title := 'Test Application Server (console)';
  Application.Run;
  Application.Free;
end.

