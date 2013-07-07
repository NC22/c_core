unit Unit1;

interface

{

 Если менять под кого то то

 1. Caption первой формы,
 2. Папка игры по умолчанию,
 3. Папка программы по умолчанию,
 4. Скрипт авторизации
 5. Иконка

}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MSXML,AbArcTyp, c_core, bsSkinCtrls, BusinessSkinForm,
  bsSkinExCtrls, bsSkinBoxCtrls, Mask, ExtCtrls, bsSkinData;

type

  TStringArray = array of string;

  TForm1 = class(TForm)
    Login: TbsSkinEdit;
    Password: TbsSkinPasswordEdit;
    Register: TbsSkinLinkLabel;
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    Button1: TbsSkinButton;
    bsSkinLabel1: TbsSkinLabel;
    bsSkinLabel2: TbsSkinLabel;
    PlayOffline: TbsSkinCheckRadioBox;
    ProgressName: TbsSkinLabel;
    ProgressBar: TbsSkinGauge;
    ProgressValue: TbsSkinLabel;
    News: TbsSkinButton;
    Options: TbsSkinButton;
    About: TbsSkinButton;
    UpdateCh: TbsSkinCheckRadioBox;
    bsSkinData1: TbsSkinData;
    bsCompressedStoredSkin1: TbsCompressedStoredSkin;
    procedure UnknownErr(Reciev : string);
    procedure BadLogin();
    procedure OldVer();
    procedure OldLauncher();
    procedure ConnectErr();
    procedure MessageShow(mess : string);
    procedure Button1Click(Sender: TObject);
    procedure AuthInfoSync;
    procedure FormCreate(Sender: TObject);
    procedure OptionsClick(Sender: TObject);
    procedure OpenWeb(Sender: TObject);
    procedure NewsClick(Sender: TObject);
    procedure AboutClick(Sender: TObject);
    procedure SyncOptions(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
     procedure Unzip(Sender : TObject; Item : TAbArchiveItem; Progress : Byte; var Abort : Boolean);
     procedure Downloading(DwnFile: downloadInfo; Sender:TObject);
  end;

var
  Form1: TForm1;
  Core : TCore;

implementation

uses Unit2, Unit3, Unit4, Unit5;

{$R *.dfm}

procedure TForm1.MessageShow(mess : string);
begin
    
 if (not Assigned(Form5)) then
       Form5:=TForm5.Create(Self);

   Form5.Show;
   Form5.bsSkinTextLabel1.Lines.Clear;
   Form5.bsSkinTextLabel1.Lines.Add(mess);

end;

procedure TForm1.BadLogin();
begin
MessageShow('Пользователь не существует или пароль введен неверно');
end;

procedure TForm1.UnknownErr(Reciev : string);
begin
MessageShow('Некорректный ответ сервера: ' + Reciev);
end;

procedure TForm1.OldVer();
begin
MessageShow('Требуемая версия клиента не соответствует версии заданой в конфигурационном файле.');
end;

procedure TForm1.OldLauncher();
begin
MessageShow('Не удалось прочитать конфигурационный файл. Возможно лаунчер устарел.');
end;

procedure TForm1.ConnectErr();
begin
MessageShow('Не удалось подключиться к серверу указанному в конфигурационном файле.');
end;

procedure TForm1.Downloading(DwnFile: downloadInfo; Sender:TObject);
var
  msg: TMsg;
begin

if ProgressValue.Visible then ProgressValue.Visible := false;

ProgressBar.MaxValue := DwnFile.size;
ProgressBar.Value := DwnFile.currentsize;

  while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
  begin
    if Msg.Message = WM_QUIT then
    begin
      exit;
    end;
    IsDialogMessage(Handle, msg);
  end;

end;

procedure TForm1.Unzip(Sender : TObject; Item : TAbArchiveItem; Progress : Byte; var Abort : Boolean);
var
  msg: TMsg;
  fname : string;
begin

if not ProgressValue.Visible then ProgressValue.Visible := true;

fname := ExtractFileName(StringReplace(Item.FileName,'/','\',[rfReplaceAll]));

if Length(fname) > 0 then begin
        ProgressName.Caption  := 'Синхронизация';
        ProgressValue.Caption := fname;
end;

  while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
  begin
    if Msg.Message = WM_QUIT then
    begin
      exit;
    end;
    IsDialogMessage(Handle, msg);
  end;

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  newOptions : globalOptions;
begin
  //доделать автонастройки
  //callback onload

  newOptions := Core.currentOptions;

  if Length(newOptions.gOptions.Game) = 0 then begin
   // messageBox(0,pChar('Выберите основную директорию игры в настройках'),'Ошибка', mb_OK);
    MessageShow('Выберите основную директорию игры в настройках');
    exit;
  end;

  newOptions.pOptions.Login := Login.Text;
  newOptions.pOptions.Password := Password.Text;

  Core.currentOptions := newOptions;

  Button1.Enabled := false;
  Options.Enabled := false;
  News.Visible := false;
  About.Visible := false;
  ProgressName.Visible := true;
  ProgressBar.Visible := true;
  ProgressName.Caption := 'Запуск';
  ProgressBar.Value := 0;

  self.Repaint;

  if PlayOffline.Checked then begin

      if not Core.IsGameWinInstalled then begin

         if Core.DownloadFileList() then begin

            Core.Play;
            Self.Close;

         end
         // else MessageShow('Ошибка сервера обновлений.');

      end
      else begin

            Core.Play;
            Self.Close;

      end;

      exit;

  end;

  ProgressName.Caption := 'Авторизация';

  if Core.Login then begin

    if UpdateCh.Checked then begin

    ProgressName.Caption := 'Обновление';

        if Core.DownloadFileList() then begin

           Core.Play;
           Self.Close;

        end;
        // else MessageShow('Ошибка сервера обновлений.');


    end
    else begin

        Core.Play;
        Self.Close;

    end;

   end;
   // else MessageShow('Ошибка авторизации.');

   Button1.Enabled       := true;
   Options.Enabled       := true;
   News.Visible          := true;
   About.Visible         := true;
   ProgressName.Visible  := false;
   ProgressBar.Visible   := false;
   ProgressValue.Visible := false;

end;


procedure TForm1.FormCreate(Sender: TObject);
var
  myOptions : globalOptions;
begin

 Core := TCore.Create();

  myOptions := Core.currentOptions;

  Login.Text := myOptions.pOptions.Login;
  Password.Text := myOptions.pOptions.Password;

 Core.DownloadConfig;
 Core.OnUnarchItem      := Unzip;
 Core.OnDownloadProcess := Downloading;
 Core.OnUnknown         := UnknownErr;
 Core.OnOldLauncher     := OldLauncher;
 Core.OnOldVer          := OldVer;
 Core.OnConnectErr      := ConnectErr;
 Core.OnBadLogin        := BadLogin;
end;

procedure TForm1.OptionsClick(Sender: TObject);
begin

 if (not Assigned(Form2)) then
       Form2:=TForm2.Create(Self);

   Form2.Show;

   Unit2.AutoConfigChanged := false;

end;

procedure TForm1.OpenWeb(Sender: TObject);
begin
WinExec(PChar('rundll32 url.dll,FileProtocolHandler '+Core.currentOptions.webOptions.Reg), SW_SHOWNORMAL);
end;

procedure TForm1.NewsClick(Sender: TObject);
begin
   if (not Assigned(Form3)) then
       Form3:=TForm3.Create(Self);
   Form3.Show;
end;

procedure TForm1.AboutClick(Sender: TObject);
begin
   if (not Assigned(Form4)) then
       Form4:=TForm4.Create(Self);
   Form4.Show;
end;

procedure TForm1.AuthInfoSync;
var
  newOptions : globalOptions;
begin

  newOptions := Core.currentOptions;

  newOptions.pOptions.Login    := Login.Text;
  newOptions.pOptions.Password := Password.Text;

  Core.currentOptions := newOptions;

end;

procedure TForm1.SyncOptions(Sender: TObject; var Action: TCloseAction);
begin

 AuthInfoSync;

end;

end.
