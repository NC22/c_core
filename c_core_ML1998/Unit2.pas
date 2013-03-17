unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Filectrl, c_core;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Label3: TLabel;
    Label4: TLabel;
    OpenDialog1: TOpenDialog;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    procedure Button2Click(Sender: TObject);
    procedure init(Sender: TObject);
    procedure ReDrawDirs();
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure minSet(Sender: TObject);
    procedure maxSet(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm2.Button2Click(Sender: TObject);
var 
  Dir: String;
  newOptions : globalOptions;
begin

  if SelectDirectory('Путь до дирректории с игрой', '', Dir) then begin
    newOptions := Core.currentOptions;
    newOptions.gOptions.Game := Dir;

    Core.currentOptions := newOptions;
    ReDrawDirs;
  end;
end;

procedure TForm2.init(Sender: TObject);
begin
ReDrawDirs;
end;

procedure TForm2.ReDrawDirs();
var getOptions : globalOptions;
begin

  getOptions := Core.currentOptions;
  if Length(getOptions.gOptions.Java) = 0 then Label3.Caption := 'Путь не задан'
  else Label3.Caption := getOptions.gOptions.Java;
  if Length(getOptions.gOptions.Java) = 0 then Label4.Caption := 'Путь не задан'
  else Label4.Caption := getOptions.gOptions.Game;

        if getOptions.gOptions.MaxMem = '128m' then ComboBox2.ItemIndex := 0
   else if getOptions.gOptions.MaxMem = '512m' then ComboBox2.ItemIndex := 1
   else if getOptions.gOptions.MaxMem = '1g'   then ComboBox2.ItemIndex := 2
   else if getOptions.gOptions.MaxMem = '2g'   then ComboBox2.ItemIndex := 3
   else if getOptions.gOptions.MaxMem = '4g'   then ComboBox2.ItemIndex := 4;

        if getOptions.gOptions.MinMem = '128m' then ComboBox1.ItemIndex := 0
   else if getOptions.gOptions.MinMem = '512m' then ComboBox1.ItemIndex := 1
   else if getOptions.gOptions.MinMem = '1g'   then ComboBox1.ItemIndex := 2
   else if getOptions.gOptions.MinMem = '2g'   then ComboBox1.ItemIndex := 3
   else if getOptions.gOptions.MinMem = '4g'   then ComboBox1.ItemIndex := 4;

end;

procedure TForm2.Button1Click(Sender: TObject);
var
  newOptions : globalOptions;
begin
if OpenDialog1.Execute then begin
  if (ExtractFileName(OpenDialog1.FileName) <> 'javaw.exe') and (ExtractFileName(OpenDialog1.FileName) <> 'java.exe') then begin
         messageBox(0,'Дерриктория не выбрана. Файлы Java Runtime не найдены.','Внимание', mb_OK);
         exit;
  end;

  newOptions := Core.currentOptions;
  newOptions.gOptions.Java := OpenDialog1.FileName;

  Core.currentOptions := newOptions;
  Label3.Caption := newOptions.gOptions.Java;
end;

end;

procedure TForm2.FormShow(Sender: TObject);
begin
   ReDrawDirs();
end;

procedure TForm2.minSet(Sender: TObject);
var newOptions : globalOptions;
begin
   newOptions := Core.currentOptions;   

   if ComboBox1.ItemIndex > ComboBox2.ItemIndex then begin

         ComboBox1.ItemIndex := ComboBox2.ItemIndex;
         maxSet(nil);

   end;

        if ComboBox1.ItemIndex = 0 then newOptions.gOptions.MinMem := '128m'
   else if ComboBox1.ItemIndex = 1 then newOptions.gOptions.MinMem := '512m'
   else if ComboBox1.ItemIndex = 2 then newOptions.gOptions.MinMem := '1g'
   else if ComboBox1.ItemIndex = 3 then newOptions.gOptions.MinMem := '2g'
   else if ComboBox1.ItemIndex = 4 then newOptions.gOptions.MinMem := '4g';

   Core.currentOptions := newOptions;
end;

procedure TForm2.maxSet(Sender: TObject);
var newOptions : globalOptions;
begin

   newOptions := Core.currentOptions;

   if ComboBox1.ItemIndex > ComboBox2.ItemIndex then begin

         ComboBox1.ItemIndex := ComboBox2.ItemIndex;
         minSet(nil);

   end;

        if ComboBox2.ItemIndex = 0 then newOptions.gOptions.MaxMem := '128m'
   else if ComboBox2.ItemIndex = 1 then newOptions.gOptions.MaxMem := '512m'
   else if ComboBox2.ItemIndex = 2 then newOptions.gOptions.MaxMem := '1g'
   else if ComboBox2.ItemIndex = 3 then newOptions.gOptions.MaxMem := '2g'
   else if ComboBox2.ItemIndex = 4 then newOptions.gOptions.MaxMem := '4g';

   Core.currentOptions := newOptions;
end;

end.
