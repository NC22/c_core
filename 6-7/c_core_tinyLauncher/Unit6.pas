unit Unit6;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, bsSkinCtrls, bsSkinBoxCtrls, BusinessSkinForm, StdCtrls, c_core, Mask;

type
  TForm6 = class(TForm)
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    StringsList: TbsSkinListBox;
    NewStringField: TbsSkinEdit;
    AddString: TbsSkinButton;
    DeleteString: TbsSkinButton;
    bsSkinLabel1: TbsSkinLabel;
    procedure AddStringClick(Sender: TObject);
    procedure DeleteStringClick(Sender: TObject);
    procedure ShowOptions(Sender: TObject);
    procedure SaveOptions(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

uses Unit1;
{$R *.dfm}

function Explode(Text, Delimiter: string) : TStringArray;
var
  i,str_key : integer;
  cur_str : string;
begin

    str_key := 0;
    setlength(result,0);

    for i:=1 to Length(Text) do
        if Text[i] <> Delimiter then begin

              cur_str := cur_str + Text[i];

           if i = Length(Text) then begin
                setlength(result,str_key+1);
                result[str_key] := cur_str;
                inc(str_key);
           end;

        end
        else if Text[i] = Delimiter then begin

                setlength(result,str_key+1);
                result[str_key] := cur_str;
                inc(str_key);
                cur_str := '';

             end
end;

procedure TForm6.AddStringClick(Sender: TObject);
var
Extension : string;
begin

if Length(NewStringField.Text) = 0 then exit;

Extension := ExtractFileExt(NewStringField.Text);

if Length(Extension) > 0 then
     StringsList.Items.Add(NewStringField.Text);  

end;

procedure TForm6.DeleteStringClick(Sender: TObject);
begin

   if StringsList.ItemIndex <> -1 then
        StringsList.Items.Delete(StringsList.ItemIndex);

end;

procedure TForm6.ShowOptions(Sender: TObject);
var
FileList   : TStringArray;
tmpOptions : globalOptions;
i          : integer;
begin

 if (not Assigned(Form1)) then exit;

 tmpOptions := Core.currentOptions;

 SetLength(FileList,0);

 FileList   := Explode(tmpOptions.webOptions.Distr_list,'|');

 StringsList.Clear;

 for i:=0 to High(FileList) do StringsList.Items.Add(FileList[i]);

end;

procedure TForm6.SaveOptions(Sender: TObject; var Action: TCloseAction);
var
tmpOptions : globalOptions;
i          : integer;
begin

 if (not Assigned(Form1)) then exit;

 tmpOptions := Core.currentOptions;
 tmpOptions.webOptions.Distr_list := '';

 for i:=1 to StringsList.Items.Count do
  if Length(tmpOptions.webOptions.Distr_list) + Length(StringsList.Items.Strings[i-1]) <= 255 then
   tmpOptions.webOptions.Distr_list := tmpOptions.webOptions.Distr_list + StringsList.Items.Strings[i-1] + '|';

 Core.currentOptions := tmpOptions;
 
end;

end.
