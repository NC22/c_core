program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  c_query in 'c_query.pas',
  c_tools in 'c_tools.pas',
  Unit2 in 'Unit2.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
