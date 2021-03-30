unit test.appsrv.core;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  mormot.core.base,          // RawUTF8
  mormot.core.data           // TSynPersistent
  ;

type
  {TDTO_Usr}
  TDTO_Usr = class(TSynPersistent)
  private
    FUsrID:      RawUTF8;
    FUserName:   RawUTF8;
  published
    property UsrID:      RawUTF8 read FUsrID      write FUsrID;
    property UserName:   RawUTF8 read FUserName   write FUserName;
  end;

  {IUsrService}
  IUsrService = interface(IInvokable)
    ['{FFF1BAFA-0E65-42AB-B110-89D844B3A342}']
    procedure GetUsr(const aUsrID: RawUTF8; out aDTO_Usr: TDTO_Usr);
  end;

  {TUsrService}
  TUsrService = class(TInterfacedObject, IUsrService)
  private
  public
    procedure GetUsr(const aUsrID: RawUTF8; out aDTO_Usr: TDTO_Usr);
  end;


implementation

{TUsrService}
procedure TUsrService.GetUsr(const aUsrID: RawUTF8; out aDTO_Usr: TDTO_Usr);
begin
  try
    aDTO_Usr.UsrID := aUsrID;
    aDTO_Usr.FUserName := 'User_' + aUsrID;

    // test
    raise EDivByZero.Create('Test exception');
  except
    on E:Exception do
      ;
  end;

end;

end.

