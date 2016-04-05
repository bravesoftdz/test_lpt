program test_inpout32;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  LPTinpout32 in 'LPTinpout32.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
