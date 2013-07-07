unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BusinessSkinForm, OleCtrls, SHDocVw, c_core , ActiveX;

type
  TForm3 = class(TForm)
    WebBrowser1: TWebBrowser;
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    procedure RefNews(Sender: TObject);
    procedure WB_LoadHTML(HTMLCode: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

uses Unit1;

{$R *.dfm}


procedure TForm3.WB_LoadHTML(HTMLCode: string);
var
  sl: TStringList;
  ms: TMemoryStream;
begin
  WebBrowser1.Navigate('about:blank');
  while WebBrowser1.ReadyState < READYSTATE_INTERACTIVE do
    Application.ProcessMessages;

  if Assigned(WebBrowser1.Document) then
  begin
    sl := TStringList.Create;
    try
      ms := TMemoryStream.Create;
      try
        sl.Text := HTMLCode;
        sl.SaveToStream(ms);
        ms.Seek(0, 0);
        (WebBrowser1.Document as
          IPersistStreamInit).Load(TStreamAdapter.Create(ms));
      finally
        ms.Free;
      end;
    finally
      sl.Free;
    end;
  end;
end;

procedure TForm3.RefNews(Sender: TObject);
var tmpOptions : globalOptions;
    HTMLSimplePage : string;
begin
  tmpOptions := Core.currentOptions;

  HTMLSimplePage := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">';
  HTMLSimplePage := HTMLSimplePage + '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">';
  HTMLSimplePage := HTMLSimplePage + '<head><title>News</title>';
  HTMLSimplePage := HTMLSimplePage + '<style type="text/css">body { font-family: sans-serif; background-color: #6c6c6c; color: #e0d0d0; }</style>';
  HTMLSimplePage := HTMLSimplePage + '</head>';

  if Length(tmpOptions.webOptions.News) = 0 then begin
  HTMLSimplePage := HTMLSimplePage + '<body><p>Страница новостей не настроена администратором.</p></body> </html>';
  WB_LoadHTML(HTMLSimplePage);
  exit;
  end;

  HTMLSimplePage := HTMLSimplePage + '<body><p>Загрузка страницы новостей...</p></body> </html>';
  WB_LoadHTML(HTMLSimplePage);
  
  WebBrowser1.Navigate(tmpOptions.webOptions.News);
end;

end.
