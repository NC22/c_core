unit Unit1;

(*******************************************************************************
*                                                                              *
* Author    :  NC22                                                            *
* Version   :  1.0                                                             *
* Date      :  02 January 2013                                                 *
* Website   :  http://www.drop.catface.ru                                      *
* Copyright :  NC22 2012-2013                                                  *
*                                                                              *
* License:                                                                     *
* Mozilla Public License Version 2.0                                           *
* http://www.mozilla.org/MPL/2.0/                                              *
*                                                                              *
*******************************************************************************)

interface

uses
  Windows, Messages, SysUtils, AbArcTyp, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  ExtCtrls, StdCtrls, ComCtrls, ImgList, c_core, c_query, c_tools,
  Buttons;

type

 TJobList = array of smallint;

 TFavInfo    = record
     Name  : array of byte;
     IP    : array of byte;
 end;

 TFavVisInfo = record
     Name  : string;
     IP    : string;
 end;

 ServInfo = record
     HostStr : string;
     Port    : Word;
 end;

 TPackedData = class(TObject)
    Serv : ServInfo;
 end;

 TrPostParams = record
      Serv    : ServInfo;
      HKey    : integer;
      SKey    : integer;
 end;

 TrSelf = record
    Handle  : Cardinal;
    Options : TrPostParams;
    InUse   : Boolean;
    Delay   : Longint;
 end;

 TrPool = array[0..10] of TrSelf;

  TForm1 = class(TForm)
    ImageList: TImageList;
    ListView1: TListView;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    StatusBar1: TStatusBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    btn: TBitBtn;
    Label5: TLabel;

    procedure init(Sender: TObject);
    procedure closeall(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BadLogin();
    procedure UnknownErr(Reciev : string);
    procedure OldVer();
    procedure OldLauncher();
    procedure ConnectErr();
    procedure Downloading(DwnFile: downloadInfo; Sender:TObject);
    procedure Unzip(Sender : TObject; Item : TAbArchiveItem; Progress : Byte; var Abort : Boolean);
    procedure btnClick(Sender: TObject);
    procedure goWeb(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure RefreshServer(Key,TrKey : smallint);
    procedure RefThemAll;
    procedure AddServer(HostStr : string; Port : Word = 25565);
    procedure ServerShow(Info : TStringArray; Connect : ServInfo; Delay : Longint);
    procedure ServerListClean;
    procedure AfterJob;

    function  FindJob : smallint;
    function  FindFreeThread : smallint;
  end;

var
  Form1: TForm1;
  Core : TCore;
  GameDir : string;

  ServList   : array of ServInfo;
  ServRefJob : TJobList;

  ThreadPool : TrPool;
  ThreadUsed : smallint;

  Wait : Boolean;
  Dead : Boolean;
  
implementation

uses Unit2;

{$R *.dfm}

Procedure Tproc(param:pointer);stdcall;
var
  getParams : TrPostParams;
  Get       : TStringArray;
  Delay     : LongInt;
  NextJob   : smallint;
begin
   if (Dead) then ExitThread(0);

   getParams := TrPostParams(param^);

   Get := MQuery(getParams.Serv.HostStr,getParams.Serv.Port);

   While (wait) do sleep(1);

   if (Dead) then ExitThread(0);     

   Wait:=true;

   Delay := GetTickCount;

    ThreadPool[getParams.HKey].Delay := Delay - ThreadPool[getParams.HKey].Delay;

    if Length(Get) > 0 then Form1.ServerShow(Get,getParams.Serv,ThreadPool[getParams.HKey].Delay)
    else Form1.ServerShow(Get,getParams.Serv,-500);

    if ThreadPool[getParams.HKey].InUse then
         CloseHandle(ThreadPool[getParams.HKey].Handle);

    ThreadPool[getParams.HKey].InUse := false;

    if ServRefJob[getParams.SKey] = -2 then ServRefJob[getParams.SKey] := -1;

    NextJob := Form1.FindJob;
    if NextJob >= 0 then Form1.RefreshServer(NextJob,getParams.HKey)
    else Form1.AfterJob;

   Wait:=false;

   ExitThread(0);

end;

procedure TForm1.AfterJob;
var
  i : integer;
begin


   for i := 0 to Length(ThreadPool)-1 do
                 if ThreadPool[i].InUse then exit;

  if FindJob < 0 then Button2.Enabled := true;

end;

procedure TForm1.ServerShow(Info : TStringArray; Connect : ServInfo; Delay : Longint);
var
  lvi  : TListItem;
begin

   // Data := TPackedData.Create();
   // Data.Serv := Connect;

   ListView1.Items.BeginUpdate;

   lvi := ListView1.Items.Add;

   // lvi.Data := Data;
   lvi.ImageIndex := 1;
   lvi.SubItems.add(Connect.HostStr);
   lvi.SubItems.add(IntToStr(Connect.Port));

   if Delay >= 0 then begin
   lvi.Caption := Info[0]; 
   lvi.SubItems.add(Info[1]+' / '+Info[2]);
   lvi.SubItems.add(IntToStr(Delay));
   end
   else begin
   lvi.ImageIndex := 0;
   lvi.Caption := Connect.HostStr;
   lvi.SubItems.add('N/A');
   lvi.SubItems.add('N/A');
   end;

   ListView1.SortType := stNone;
   ListView1.Items.EndUpdate;

end;

procedure TForm1.BadLogin();
begin
  StatusBar1.SimpleText := 'Пользователь не существует или пароль введен неверно';
end;

procedure TForm1.UnknownErr(Reciev : string);
begin
  StatusBar1.SimpleText := 'Сервер вернул некорректный ответ: '+ Reciev;
end;

procedure TForm1.OldVer();
begin
  StatusBar1.SimpleText := 'Версия клиент не соответствует версии требуемой сервером';
end;

procedure TForm1.OldLauncher();
begin
  StatusBar1.SimpleText := 'Лаунчер устарел';
end;

procedure TForm1.ConnectErr();
begin
  StatusBar1.SimpleText := 'Сервер авторизации недоступен';
end;

procedure TForm1.Downloading(DwnFile: downloadInfo; Sender:TObject);
var
 total, cur : integer;
begin
cur := DwnFile.currentsize;
total := DwnFile.size;

   StatusBar1.SimpleText := '[Загрузка обновлений] [' + IntToStr(round((cur/total)*100)) + '%] Файл: ' + DwnFile.name;
end;

procedure TForm1.Unzip(Sender : TObject; Item : TAbArchiveItem; Progress : Byte; var Abort : Boolean);
var
  fname : string;
begin

fname := ExtractFileName(StringReplace(Item.FileName,'/','\',[rfReplaceAll]));

if Length(fname) > 0 then
  StatusBar1.SimpleText := '[Синхронизация] Файл: ' + fname;
end;

procedure TForm1.ServerListClean;
var
  i : integer;
begin

   for i := 0 to ListView1.Items.Count-1 do
     if assigned(ListView1.Items.Item[i].Data) then
        TPackedData(ListView1.Items.Item[i].Data).Free;

    ListView1.Clear;

end;

procedure TForm1.RefreshServer(Key,TrKey : smallint);
begin

  if ThreadPool[TrKey].InUse then exit;

  if ServRefJob[Key] >= 0 then ServRefJob[Key] := -2
  else exit;

  ThreadPool[TrKey].Options.Serv.HostStr := ServList[Key].HostStr;
  ThreadPool[TrKey].Options.Serv.Port    := ServList[Key].Port;
  ThreadPool[TrKey].Options.HKey         := TrKey;
  ThreadPool[TrKey].Options.SKey         := Key;
 // ThreadPool[TrKey].Options.SelfP        := Addr(Form1);
  ThreadPool[TrKey].InUse                := true;
  ThreadPool[TrKey].Delay                := GetTickCount;
  ThreadPool[TrKey].Handle               := CreateThread(nil, 0, @Tproc, @ThreadPool[TrKey].Options, 0, ThreadPool[TrKey].Handle);

end;

function TForm1.FindJob : smallint;
var
   i : integer;
begin

   result := -1;

   for i := 0 to Length(ServRefJob)-1 do
     if ServRefJob[i] >= 0 then begin
        result := ServRefJob[i];
        break;
     end;

end;

function TForm1.FindFreeThread : smallint;
var
   i : integer;
begin

   result := -1;

   for i := 0 to Length(ThreadPool)-1 do
     if not ThreadPool[i].InUse then begin
        result := i;
        break;
     end;

end;


procedure TForm1.RefThemAll;
var
   i : integer;
   ThreadForJob : smallint;
begin

   if Length(ServList) = 0 then exit; 

   for i := 0 to Length(ServList)-1 do

    if ServRefJob[i] = -1 then begin

     ServRefJob[i] := i;

     ThreadForJob := FindFreeThread;

     if ThreadForJob >= 0 then
        RefreshServer(ServRefJob[i],ThreadForJob);

     end;

end;

procedure TForm1.AddServer(HostStr : string; Port : Word = 25565);
var
  Key : integer;
begin

 Key := Length(ServList);

 SetLength(ServList,Key+1);

 ServList[Key].HostStr := HostStr;
 ServList[Key].Port := Port;

 SetLength(ServRefJob, Length(ServList));
 ServRefJob[Length(ServList)-1] := -1;
end;

procedure TForm1.init(Sender: TObject);
var
   i : integer;
   getOptions : globalOptions;
begin

 Dead := false;

{ Launcher }

 Core := TCore.Create('ML1998','TWEBMCR'); // Настройки по умолчанию вшиты в c_core

 Core.OnUnarchItem      := Unzip;       // Разархивирования zip архива
 Core.OnDownloadProcess := Downloading; // Процесс загрузки файла
 Core.OnUnknown         := UnknownErr;  // Неизвестный ответ от сервера
 Core.OnOldLauncher     := OldLauncher; // Протокол лаунчера устарел ( ошибка возникает при неудачном чтении файла автонастроек \ настроек )
 Core.OnOldVer          := OldVer;      // Ответ сервера - Old version
 Core.OnConnectErr      := ConnectErr;  // Сервер авторизации недоступен
 Core.OnBadLogin        := BadLogin;    // Ответ сервера - Bad Login

 Core.DownloadConfig;   // В любом случае пробуем скачать конфиг файл для автонастройки

 // Загружаем необходимую информацию из ядра

 getOptions := Core.currentOptions;
 Edit1.Text := getOptions.pOptions.Login;
 Edit2.Text := getOptions.pOptions.Password;

 GameDir := getOptions.gOptions.Game;
 StatusBar1.SimpleText := 'Игра: ' + GameDir;

{ Server list init }

   for i := 0 to Length(ThreadPool)-1 do ThreadPool[i].InUse := false;

  SetLength(ServList,0);
  SetLength(ServRefJob,0);

  Wait:=false;

  SocketInit;
  SetLength(ServRefJob, Length(ServList));

  for i := 0 to Length(ServRefJob)-1 do ServRefJob[i] := -1;

  Button2.OnClick(nil);
end;

procedure TForm1.closeall(Sender: TObject; var Action: TCloseAction);
var
  i : integer;
begin
    Dead := true;

    for i := 0 to Length(ThreadPool)-1 do
      if ThreadPool[i].InUse then begin
       CloseHandle(ThreadPool[i].Handle);
      end;

   SocketEnd;

end;

procedure TForm1.Button2Click(Sender: TObject);
var
 FOptions    : file of byte;
 OptionsFile : string;
 FileContent : byte;
 OutPut      : array of byte;
 char_key    : integer;
 i,b         : integer;

 Mems    : TByteArray;
 Tmp     : TByteArray;
 FavInfo : array of TFavInfo;
 Cut     : array of byte;

 FavInfoStr : array of TFavVisInfo;
 TmpCon  : TStringArray;
begin

  char_key := 0;
  SetLength(OutPut,0);
  SetLength(Mems,0);
  SetLength(Tmp,0);
  SetLength(TmpCon,0);
  SetLength(ServList,0);
  SetLength(ServRefJob,0);
  
  OptionsFile := GameDir + 'servers.dat';

  if FileExists(OptionsFile) = false then exit;

  AssignFile(FOptions, OptionsFile);
  Reset(FOptions);

  while (not EOF(FOptions)) do begin
        read(FOptions, FileContent);
        setlength(OutPut,char_key+1);
        OutPut[char_key] := FileContent;
        inc(char_key);
  end;

  CloseFile(FOptions);

  setlength(Cut,0);
  setlength(Cut,6);
  Cut[0] := $04; Cut[1] := $6E; Cut[2] := $61; Cut[3] := $6D; Cut[4] := $65; Cut[5] := $00;
  Mems := SpecExplode(OutPut,Cut);

  if Length(Mems) < 2 then exit;

  SetLength(FavInfo,Length(Mems)-1);

  for i := 0 to Length(FavInfo)-1 do begin
        setlength(Cut,0);
        setlength(Cut,6);
        Cut[0] := $08; Cut[1] := $00; Cut[2] := $02; Cut[3] := $69; Cut[4] := $70; Cut[5] := $00;
        Tmp := SpecExplode(Mems[i+1],Cut);

       if Length(Tmp) = 2 then begin

                setlength(FavInfo[i].Name,Length(Tmp[0]));
                WriteBytes(FavInfo[i].Name,Tmp[0]);

                setlength(FavInfo[i].IP,Length(Tmp[1]));
                WriteBytes(FavInfo[i].IP,Tmp[1]);

        end
        else begin
           setlength(FavInfo[i].Name,1); setlength(FavInfo[i].IP,1);
           FavInfo[i].Name[0] := $FF; FavInfo[i].IP[0] := $FF;
        end;
  end;

 // ShowMessage(inttostr(length(mems)));

 if Length(FavInfo) < 1 then exit;

 char_key := 0;
 for i := 0 to High(FavInfo) do begin

    if FavInfo[i].Name[0] = $FF then continue;


    setlength(FavInfoStr,char_key+1);

    FavInfoStr[char_key].Name := '';
    FavInfoStr[char_key].IP   := '';

    for b:=1 to FavInfo[i].Name[0] do FavInfoStr[char_key].Name := FavInfoStr[char_key].Name + Char(FavInfo[i].Name[b]);

    for b:=1 to FavInfo[i].IP[0] do FavInfoStr[char_key].IP := FavInfoStr[char_key].IP + Char(FavInfo[i].IP[b]);

    TmpCon := Explode(FavInfoStr[char_key].IP,':');

         if Length(TmpCon) = 2 then  AddServer(TmpCon[0],StrToInt(TmpCon[1]))
    else if Length(TmpCon) = 1 then  AddServer(TmpCon[0]);

    inc(char_key);

 end;

 Button2.Enabled := false;

 ServerListClean;

 RefThemAll;
 
  //ShowMessage(FileContent);

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  newOptions : globalOptions;
begin

 Button1.Enabled := false;

 newOptions := Core.currentOptions;

 newOptions.pOptions.Login    := Edit1.Text;
 newOptions.pOptions.Password := Edit2.Text;

 Core.currentOptions := newOptions;

 if Core.Login then begin
   if Core.DownloadFileList() then begin
      Core.Play;
      Self.Close;
   end
 end;

 Button1.Enabled := true;
end;

procedure TForm1.btnClick(Sender: TObject);
begin

 if (not Assigned(Form2)) then
       Form2:=TForm2.Create(Self);

   Form2.Show;

end;

procedure TForm1.goWeb(Sender: TObject);
var
  command : string;
begin

 command := 'rundll32 url.dll,FileProtocolHandler ' + string(Core.currentOptions.webOptions.Reg);

 WinExec(PAnsiChar(PAnsiString(command)), SW_SHOWNORMAL);
end;

end.
