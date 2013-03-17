unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, c_core, bsSkinCtrls, BusinessSkinForm, StdCtrls, bsSkinExCtrls;

type
  TForm4 = class(TForm)
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    bsSkinButton1: TbsSkinButton;
    ProgName: TbsSkinLabel;
    Version: TbsSkinLabel;
    bsSkinLabel1: TbsSkinLabel;
    Register: TbsSkinLinkLabel;
    procedure RefVersion(Sender: TObject);
    procedure bsSkinButton1Click(Sender: TObject);
    procedure RegisterClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm4.RefVersion(Sender: TObject);
begin

 ProgName.Caption := Core._Progname;
 Version.Caption := Core._Version;

end;

procedure TForm4.bsSkinButton1Click(Sender: TObject);
begin
   Self.Close;
end;

procedure TForm4.RegisterClick(Sender: TObject);
begin
   WinExec(PChar('rundll32 url.dll,FileProtocolHandler http://drop.catface.ru'), SW_SHOWNORMAL);
end;

end.
