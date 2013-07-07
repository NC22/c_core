unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BusinessSkinForm, bsSkinCtrls, bsSkinShellCtrls, StdCtrls, Mask, c_core,
  bsSkinBoxCtrls, bsSkinData, bsPngImageList;

type
  TForm2 = class(TForm)
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    Auth: TbsSkinEdit;
    Distr: TbsSkinEdit;
    bsSkinLabel4: TbsSkinLabel;
    SelectDirectoryDialog1: TbsSkinSelectDirectoryDialog;
    Game: TbsSkinLabel;
    ChangeDir: TbsSkinButton;
    bsSkinLabel3: TbsSkinLabel;
    bsSkinLabel5: TbsSkinLabel;
    bsSkinLabel6: TbsSkinLabel;
    bsSkinPanel1: TbsSkinPanel;
    MinMem: TbsSkinComboBox;
    MaxMem: TbsSkinComboBox;
    AdminPanel: TbsSkinPanel;
    bsSkinLabel7: TbsSkinLabel;
    bsSkinLabel8: TbsSkinLabel;
    Reg: TbsSkinEdit;
    AutoScript: TbsSkinEdit;
    bsSkinLabel9: TbsSkinLabel;
    ForbitOptions: TbsSkinCheckRadioBox;
    bsSkinLabel10: TbsSkinLabel;
    Pass: TbsSkinEdit;
    bsSkinLabel11: TbsSkinLabel;
    JavaDir: TbsSkinLabel;
    ChangeJava: TbsSkinButton;
    Version: TbsSkinEdit;
    bsSkinLabel12: TbsSkinLabel;
    bsSkinLabel2: TbsSkinLabel;
    bsSkinLabel1: TbsSkinLabel;
    SelectFileDialog1: TbsSkinOpenDialog;
    News: TbsSkinEdit;
    bsSkinNewsLabel: TbsSkinLabel;
    bsSkinButton1: TbsSkinButton;
    bsSkinButton2: TbsSkinButton;
    SaveDialog1: TbsSkinSaveDialog;
    bsSkinButton3: TbsSkinButton;
    bsSkinButton4: TbsSkinButton;
    procedure ChangeDirClick(Sender: TObject);
    procedure RefreshForm(Sender: TObject);
    procedure ForbitOptionsClick(Sender: TObject);
    procedure MaxMemSet(Sender: TObject);
    procedure SaveChanges(Sender: TObject; var Action: TCloseAction);
    procedure MinMemSet(Sender: TObject);
    procedure bsSkinButton1Click(Sender: TObject);
    procedure LoadClick(Sender: TObject);
    procedure SaveCurrent;
    procedure byDefaults(Sender: TObject);
    procedure AutoScriptChanged(Sender: TObject);
    procedure bsSkinButton4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  AutoConfigChanged : boolean;

implementation

uses Unit1, Unit6;

{$R *.dfm}

procedure TForm2.SaveCurrent;
var newOptions : globalOptions;
    Validator  : integer;
begin

  newOptions := Core.currentOptions;

  if ForbitOptions.Checked and ForbitOptions.Enabled then begin

       newOptions.sysOptions.Forbit := true;

  end;

  newOptions.webOptions.Login      := Auth.Text;
  newOptions.webOptions.Distr      := Distr.Text;
  newOptions.webOptions.AutoConfig := AutoScript.Text;
  newOptions.webOptions.News       := News.Text;

  if TryStrToInt(Version.Text, Validator) then
  newOptions.webOptions.LVER       := Version.Text;

  if (Length(Pass.Text) > 0) and (TryStrToInt(Pass.Text, Validator)) then
  newOptions.sysOptions.Depass     := Pass.Text;
  if Length(Pass.Text) = 0 then
  newOptions.sysOptions.Depass     := '';

  newOptions.webOptions.Reg        := Reg.Text;

  Core.currentOptions := newOptions;

end;

procedure TForm2.ChangeDirClick(Sender: TObject);
var
  newOptions : globalOptions;
begin

   if Sender = ChangeDir then begin

         if SelectDirectoryDialog1.Execute then begin

          newOptions := Core.currentOptions;
          newOptions.gOptions.Game := SelectDirectoryDialog1.Directory + '\';

          Core.currentOptions := newOptions;
          Game.Caption := newOptions.gOptions.Game;

             if not FileExists(SelectDirectoryDialog1.Directory+'\bin\minecraft.jar') then
             messageBox(0,'Игра не обнаружена в папке.','Внимание', mb_OK);

          end;
   end;

   if Sender = ChangeJava then begin

   //путь до файла сделать а не до папки

         if SelectFileDialog1.Execute then begin

             if (ExtractFileName(SelectFileDialog1.FileName) <> 'javaw.exe') and (ExtractFileName(SelectFileDialog1.FileName) <> 'java.exe') then begin
             messageBox(0,'Дерриктория не выбрана. Файлы Java Runtime не найдены.','Внимание', mb_OK);
             exit;
             end;

          newOptions := Core.currentOptions;

          newOptions.gOptions.Java := SelectFileDialog1.FileName;

          Core.currentOptions := newOptions;
          JavaDir.Caption := newOptions.gOptions.Java;

          end;
   end;

end;

procedure TForm2.RefreshForm(Sender: TObject);
var tmpOptions : globalOptions;
begin

   // FileButton.ImageIndex := 0;

   if (not Assigned(Form1)) then exit;

   // MaxMem.ItemIndex задавать


   tmpOptions      := Core.currentOptions;
   Game.Caption    := tmpOptions.gOptions.Game;
   JavaDir.Caption := tmpOptions.gOptions.Java;
   Auth.Text       := tmpOptions.webOptions.Login;
   News.Text       := tmpOptions.webOptions.News;
   AutoScript.Text := tmpOptions.webOptions.AutoConfig;
   Reg.Text        := tmpOptions.webOptions.Reg;
   Pass.Text       := tmpOptions.sysOptions.Depass;


   if tmpOptions.webOptions.Login = 'hidden' then begin

         Auth.Text := 'Изменение недоступно';
         Auth.Enabled := false;

   end
   else  Auth.Enabled := true;

    Version.Text := tmpOptions.webOptions.LVER;

   if tmpOptions.webOptions.LVER = 'hidden' then begin

         Version.Text := '?';
         Version.Enabled := false;

   end
   else  Version.Enabled := true;

   Distr.Text := tmpOptions.webOptions.Distr;

   if tmpOptions.webOptions.Login = 'hidden' then begin

         Distr.Text := 'Изменение недоступно';
         Distr.Enabled := false;

   end
   else  Distr.Enabled := true;

   if tmpOptions.gOptions.MaxMem = '128m' then MaxMem.ItemIndex := 0
   else if tmpOptions.gOptions.MaxMem = '512m' then MaxMem.ItemIndex := 1
   else if tmpOptions.gOptions.MaxMem = '1g' then MaxMem.ItemIndex := 2
   else if tmpOptions.gOptions.MaxMem = '2g' then MaxMem.ItemIndex := 3
   else if tmpOptions.gOptions.MaxMem = '4g' then MaxMem.ItemIndex := 4;

   if tmpOptions.gOptions.MinMem = '128m' then MinMem.ItemIndex := 0
   else if tmpOptions.gOptions.MinMem = '512m' then MinMem.ItemIndex := 1
   else if tmpOptions.gOptions.MinMem = '1g' then MinMem.ItemIndex := 2
   else if tmpOptions.gOptions.MinMem = '2g' then MinMem.ItemIndex := 3
   else if tmpOptions.gOptions.MinMem = '4g' then MinMem.ItemIndex := 4;

   if tmpOptions.sysOptions.Forbit then begin
       Form2.ClientHeight    := 264;
       AdminPanel.Height     := 73;
       ForbitOptions.Enabled := false;
       ForbitOptions.Visible := false;
       ForbitOptions.Checked := true
   end
   else begin
       Form2.ClientHeight    := 432;
       AdminPanel.Height     := 241;
       ForbitOptions.Enabled := true;
       ForbitOptions.Visible := true;
       ForbitOptions.Checked := false
   end;

end;

procedure TForm2.ForbitOptionsClick(Sender: TObject);
begin

        if ForbitOptions.Checked and ForbitOptions.Enabled then
            messageBox(0,'Внимание. После закрытия окна настроек вы больше не сможете их изменить. Это опция используется только администратором.','Внимание', mb_OK);

end;

procedure TForm2.MaxMemSet(Sender: TObject);
var newOptions : globalOptions;
begin

   newOptions := Core.currentOptions;

   if MaxMem.ItemIndex = 0 then newOptions.gOptions.MaxMem := '128m'
   else if MaxMem.ItemIndex = 1 then newOptions.gOptions.MaxMem := '512m'
   else if MaxMem.ItemIndex = 2 then newOptions.gOptions.MaxMem := '1g'
   else if MaxMem.ItemIndex = 3 then newOptions.gOptions.MaxMem := '2g'
   else if MaxMem.ItemIndex = 4 then newOptions.gOptions.MaxMem := '4g';

   if MinMem.ItemIndex > MaxMem.ItemIndex then begin

         MinMem.ItemIndex := MaxMem.ItemIndex;
         MinMemSet(nil);

   end;

   Core.currentOptions := newOptions;

end;

procedure TForm2.SaveChanges(Sender: TObject; var Action: TCloseAction);
begin

 SaveCurrent;

 if (AutoConfigChanged) and (messageBox(0,'Скрипт автонастройки изменился, синхронизировать настройки прямо сейчас ?','Внимание',MB_OKCANCEL or mb_iconquestion) = 1) then

     Core.DownloadConfig;


end;

procedure TForm2.MinMemSet(Sender: TObject);
var newOptions : globalOptions;
begin
   newOptions := Core.currentOptions;

        if MinMem.ItemIndex = 0 then newOptions.gOptions.MinMem := '128m'
   else if MinMem.ItemIndex = 1 then newOptions.gOptions.MinMem := '512m'
   else if MinMem.ItemIndex = 2 then newOptions.gOptions.MinMem := '1g'
   else if MinMem.ItemIndex = 3 then newOptions.gOptions.MinMem := '2g'
   else if MinMem.ItemIndex = 4 then newOptions.gOptions.MinMem := '4g';

   if MinMem.ItemIndex > MaxMem.ItemIndex then begin

         MinMem.ItemIndex := MaxMem.ItemIndex;
         MaxMemSet(nil);

   end;

   Core.currentOptions := newOptions;

end;

procedure TForm2.bsSkinButton1Click(Sender: TObject);
begin
   if SaveDialog1.Execute then begin

        SaveCurrent;

        Core.SaveAuthOptions(SaveDialog1.FileName);
        
   end;

end;

procedure TForm2.LoadClick(Sender: TObject);
begin

SelectFileDialog1.Filter := 'Auth File|*.ac';

 if SelectFileDialog1.Execute and Core.LoadAuthOptions(SelectFileDialog1.FileName) then
 RefreshForm(nil);
    {
      if SelectFileDialog1.Execute and Core.LoadAuthOptions(SelectFileDialog1.FileName) then
      begin
          newOptions := Core.currentOptions;

          Auth.Text        := newOptions.webOptions.Login       ;
          Distr.Text       := newOptions.webOptions.Distr       ;
          AutoScript.Text  := newOptions.webOptions.AutoConfig  ;
          News.Text        := newOptions.webOptions.News        ;
          Version.Text     := newOptions.webOptions.LVER        ;
          Reg.Text         := newOptions.webOptions.Reg         ;
          Pass.Text        := newOptions.sysOptions.Depass      ;

         if newOptions.sysOptions.Forbit then
                ForbitOptions.Checked := true
         else   ForbitOptions.Checked := false;


      end; }

SelectFileDialog1.Filter := 'Java Console|java.exe|Java window|javaw.exe';

end;

procedure TForm2.byDefaults(Sender: TObject);
begin

    Core.SetDefaultAuthOptions;
    AutoConfigChanged := true;
    RefreshForm(nil);
end;

procedure TForm2.AutoScriptChanged(Sender: TObject);
begin

  if Length(AutoScript.Text) = 0 then  AutoConfigChanged := false
  else                                 AutoConfigChanged := true;

end;

procedure TForm2.bsSkinButton4Click(Sender: TObject);
begin

   if (not Assigned(Form6)) then
       Form6:=TForm6.Create(Self);

   Form6.Show;
end;

end.
