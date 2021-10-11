program PView;

uses
  Forms,
  uPView in 'uPView.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Process View';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
