program KeyScanLogger;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {frmMain};

{$R *.res}

begin
  Application.Title := 'KeyScan Logger Delphi';
  Application.MainFormOnTaskbar := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.