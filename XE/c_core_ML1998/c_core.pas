unit c_core;

(* ******************************************************************************
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
  ****************************************************************************** *)

interface

uses Windows, SysUtils, idHTTP, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdAntiFreeze, IdMultipartFormData, Classes,
  AbUtils, AbArcTyp, AbUnZper, ShlObj, MD5, c_crypt;

type

  TStringArray = array of string;

  TauthInfo = record
    GameBuild: integer;
    Download: string[64];
    RealLogin: string[64];
    SessionId: string[64];
  end;

  downloadInfo = record
    name: string[255];
    currentsize: integer;
    hash: string[32];
    size: integer;
  end;

  TDwnEvent = procedure(DwnFile: downloadInfo; Sender: TObject) of object;
  TEvent = procedure of object;
  TUnknownEvent = procedure(Response: string) of object;

  playerOptions = record
    Login: string[255];
    Password: string[255];
  end;

  gameOptions = record
    Java: string[255];
    Game: string[255];
    MineHash: string[255];
    MaxMem: string[32];
    MinMem: string[32];
  end;

  webOptions = record
    Login: string[255];
    LVER: string[255];
    AutoConfig: string[255];
    Reg: string[255];
    Distr: string[255];
    Distr_list: string[255];
    News: string[255];
  end;

  systemOptions = record
    Forbit: boolean;
    Depass: string[255];
  end;

  globalOptions = packed record
    pOptions: playerOptions;
    gOptions: gameOptions;
    webOptions: webOptions;
    sysOptions: systemOptions;
  end;

  prefabOptions = packed record
    webOptions: webOptions;
    sysOptions: systemOptions;
  end;

  TCore = Class
  private
    PROGMA: string;
    VERSION: string;
    RootDir: string;
    PassBase: Word;
    Options: globalOptions;
    AuthInfo: TauthInfo;
    Download: downloadInfo;
    UnzipFailTrigger: boolean;
    FOnDwnProcess: TDwnEvent;
    FOldEvent: TEvent;
    FOldVer: TEvent;
    FBadLogin: TEvent;
    FConnErr: TEvent;
    FUnknownErr: TUnknownEvent;
    FOnDwnEnd: TDwnEvent;
    FOnUnarchItem: TAbArchiveItemProgressEvent;
    FOnFailItem: TAbArchiveItemFailureEvent;
    function GetSysDir(direcoty: smallint): string;
    function LoadOptions: boolean;
    function PrivateGetOptions: globalOptions;
    function GetOptions: globalOptions;
    function GetMD5Hash(fname: string): string;
    function DownloadMD5(fname: string): string;
    function NeedToFileUpdate(fname, hash: string): boolean;
    function ZipUnzip(RootDir, fname: string; delete: boolean): boolean;
    function ValidConfig(Depass, VERSION: string): boolean;
    function IsNativesWinInstalled: boolean;
    function CryptMe(somestring: string; pass: string): string;
    function DeCryptMe(somestring: string; pass: string): string;
    function Explode(Text, Delimiter: string): TStringArray;
    function FindJava: boolean;
    procedure PrivateSetOptions(newOptions: globalOptions);
    procedure SetOptions(newOptions: globalOptions);
    procedure OldLauncherTicket;
    procedure HTTPmechWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure HTTPmechWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure HTTPmechWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
    procedure UnzipItemWork(Sender: TObject; Item: TAbArchiveItem;
      Progress: Byte; var Abort: boolean);
    procedure UnzipItemFail(Sender: TObject; Item: TAbArchiveItem;
      ProcessType: TAbProcessType; ErrorClass: TAbErrorClass;
      ErrorCode: integer);
    procedure SaveOptions;
  protected
    procedure ExecEventDwnProcess(DwnFile: downloadInfo); dynamic;
    procedure ExecEventDwnEnd(DwnFile: downloadInfo); dynamic;
    procedure ExecEventOldLauncher(); dynamic;
    procedure ExecEventOldVer(); dynamic;
    procedure ExecEventBadLogin(); dynamic;
    procedure ExecEventConnectErr(); dynamic;
    procedure ExecEventUnknown(Response: string); dynamic;
    procedure ExecEventUnarchItem(Item: TAbArchiveItem; Progress: Byte;
      var Abort: boolean); dynamic;
    procedure ExecEventFailItem(Item: TAbArchiveItem;
      ProcessType: TAbProcessType; ErrorClass: TAbErrorClass;
      ErrorCode: integer); dynamic;
  public
    property OnDownloadProcess: TDwnEvent read FOnDwnProcess
      write FOnDwnProcess;
    property OnDownloadEnd: TDwnEvent read FOnDwnEnd write FOnDwnEnd;
    property OnOldLauncher: TEvent read FOldEvent write FOldEvent;
    property OnOldVer: TEvent read FOldVer write FOldVer;
    property OnBadLogin: TEvent read FBadLogin write FBadLogin;
    property OnUnknown: TUnknownEvent read FUnknownErr write FUnknownErr;
    property OnConnectErr: TEvent read FConnErr write FConnErr;
    property OnUnzipItemFail: TAbArchiveItemFailureEvent read FOnFailItem
      write FOnFailItem;
    property OnUnarchItem: TAbArchiveItemProgressEvent read FOnUnarchItem
      write FOnUnarchItem;
    property _Version: string read VERSION;
    property _Progname: string read PROGMA;
    procedure Play;
    procedure SaveAuthOptions(fname: string);
    procedure SetDefaultAuthOptions;
    function DownloadFile(fname: string): boolean;
    function DownloadFileList(): boolean;
    function DownloadConfig: boolean;
    function Login: boolean;
    function IsGameWinInstalled: boolean;
    function LoadAuthOptions(fname: string): boolean;
    Constructor Create(PROG: string = 'TinyLauncher';
      GameDirName: string = 'TWEBMCR');
    Destructor Destroy; override;
    property currentOptions: globalOptions read GetOptions write SetOptions;
  end;

implementation

Constructor TCore.Create(PROG: string = 'TinyLauncher';
  GameDirName: string = 'TWEBMCR');
var
  tmp: string;
begin
  Inherited Create;

  PROGMA := PROG;
  VERSION := '1.0';

  PassBase := 65420;

  FOldVer := nil;
  FOnDwnProcess := nil;
  FOldEvent := nil;
  FOnDwnEnd := nil;
  FOnUnarchItem := nil;
  FOnFailItem := nil;

  RootDir := GetSysDir($001A) + '\' + PROGMA + '\';

  AuthInfo.GameBuild := 0;
  AuthInfo.Download := '';
  AuthInfo.RealLogin := '';
  AuthInfo.SessionId := '';

  if LoadOptions then
    exit;

  { SET DEFAULTS }

  Options.gOptions.Java := '';
  Options.gOptions.Game := '';
  Options.gOptions.MineHash := '';
  Options.gOptions.MaxMem := '512m';
  Options.gOptions.MinMem := '512m';

  FindJava;

  tmp := GetSysDir($001A); // AppData directory

  if (Length(GameDirName) = 0) then
  begin

    if (FileExists(tmp + '\.minecraft\bin\minecraft.jar')) then
      Options.gOptions.Game := tmp + '\.minecraft\'
    else if (FileExists(tmp + '\Roaming\.minecraft\bin\minecraft.jar')) then
      Options.gOptions.Game := tmp + '\Roaming\.minecraft\';

    GameDirName := 'DefaultGameDir';
  end;

  if (Length(Options.gOptions.Game) = 0) then
  begin

    if not DirectoryExists(tmp + '\.' + GameDirName + '\') then
      CreateDirectory(PWideChar(tmp + '\.' + GameDirName + '\'), nil);
    Options.gOptions.Game := tmp + '\.' + GameDirName + '\'

  end;

  SetDefaultAuthOptions;
  SaveOptions;

end;

destructor TCore.Destroy;
begin

  inherited;
end;

procedure TCore.SetDefaultAuthOptions;
begin

  Options.pOptions.Login := '';
  Options.pOptions.Password := '';

  Options.sysOptions.Forbit := false;
  Options.sysOptions.Depass := '';

  Options.webOptions.LVER := '13';
  Options.webOptions.Login := 'https://login.minecraft.net/';
  Options.webOptions.Reg := '';
  Options.webOptions.Distr := 'http://s3.amazonaws.com/MinecraftDownload/';
  Options.webOptions.Distr_list :=
    'minecraft.jar|jinput.jar|lwjgl.jar|lwjgl_util.jar|windows_natives.jar';
  Options.webOptions.AutoConfig := 'http://craft.catface.ru/config/config.ac';
  Options.webOptions.News := '';

end;

function TCore.FindJava: boolean;
var
  tmp: string;
  i: integer;
begin

  result := false;

  tmp := GetSysDir($0026);

  for i := 6 to 9 do
    if (FileExists(tmp + '\Java\jre' + IntToStr(i) + '\bin\javaw.exe')) then
    begin
      Options.gOptions.Java := tmp + '\Java\jre' + IntToStr(i) +
        '\bin\javaw.exe';
      result := true;
      SaveOptions;
      exit
    end;

  if messageBox(0,
    'Программа не смогла найти библиотеки Java, открыть http://www.java.com/ru/download/ и скачать их прямо сейчас ? ',
    'Внимание', MB_OKCANCEL or mb_iconquestion) = 1 then
    WinExec(PAnsiChar
      ('rundll32 url.dll,FileProtocolHandler http://www.java.com/ru/download/'),
      SW_SHOWNORMAL);
end;

function TCore.Explode(Text, Delimiter: string): TStringArray;
var
  i, str_key: integer;
  cur_str: string;
begin

  str_key := 0;
  setlength(result, 0);

  for i := 1 to Length(Text) do
    if Text[i] <> Delimiter then
    begin

      cur_str := cur_str + Text[i];

      if i = Length(Text) then
      begin
        setlength(result, str_key + 1);
        result[str_key] := cur_str;
        inc(str_key);
      end;

    end
    else if Text[i] = Delimiter then
    begin

      setlength(result, str_key + 1);
      result[str_key] := cur_str;
      inc(str_key);
      cur_str := '';

    end
end;

procedure TCore.Play;
var
  Params, Launch, GameFiles: AnsiString;
  TmpOptions: globalOptions;
  PlayOnline: boolean;
  // debug : string;
begin

  PlayOnline := true;

  TmpOptions := PrivateGetOptions;

  // debug := TmpOptions.gOptions.MineHash + ' | '+TmpOptions.gOptions.Game;

  if (Length(AuthInfo.RealLogin) = 0) or (Length(AuthInfo.SessionId) = 0) then
    PlayOnline := false;

  if (PlayOnline) and (TmpOptions.gOptions.MineHash <> 'none') and
    (NeedToFileUpdate(string(TmpOptions.gOptions.Game + 'bin\minecraft.jar'),
    string(TmpOptions.gOptions.MineHash))) then
    exit;

  if Length(TmpOptions.pOptions.Login) = 0 then
    TmpOptions.pOptions.Login := 'Default';

  if not PlayOnline then
    Params := '"' + TmpOptions.pOptions.Login + '"'
  else
    Params := '"' + AuthInfo.RealLogin + '" "' + AuthInfo.SessionId + '"';

  GameFiles := TmpOptions.gOptions.Game + 'bin\minecraft.jar;';
  GameFiles := GameFiles + TmpOptions.gOptions.Game + 'bin\lwjgl.jar;';
  GameFiles := GameFiles + TmpOptions.gOptions.Game + 'bin\lwjgl_util.jar;';
  GameFiles := GameFiles + TmpOptions.gOptions.Game + 'bin\jinput.jar;';

  Launch := ' -Xms' + TmpOptions.gOptions.MinMem + ' -Xmx' +
    TmpOptions.gOptions.MaxMem + ' -Djava.library.path="' +
    TmpOptions.gOptions.Game + 'bin\natives"' + ' -cp "' + GameFiles + '"' +
    ' net.minecraft.client.Minecraft ' + Params;

  if Length(TmpOptions.gOptions.Java) = 0 then
  begin
    if FindJava then
      TmpOptions := PrivateGetOptions
    else
      exit;
  end;

  WinExec(PAnsiChar(TmpOptions.gOptions.Java + Launch), SW_SHOW);

end;

function TCore.GetMD5Hash(fname: string): string;
var
  MD5: TMd5;
begin

  if FileExists(fname) = false then
  begin
    result := '';
    exit
  end;

  MD5 := TMd5.Create;
  result := MD5.GetHash(fname);
  MD5.free;
end;

procedure TCore.ExecEventBadLogin();
begin
  if Assigned(FBadLogin) then
    FBadLogin();
end;

procedure TCore.ExecEventUnknown(Response: string);
begin
  if Assigned(FUnknownErr) then
    FUnknownErr(Response);
end;

procedure TCore.ExecEventConnectErr();
begin
  if Assigned(FConnErr) then
    FConnErr();
end;

procedure TCore.ExecEventOldVer();
begin
  if Assigned(FOldVer) then
    FOldVer();
end;

procedure TCore.ExecEventOldLauncher();
begin
  if Assigned(FOldEvent) then
    FOldEvent();
end;

procedure TCore.ExecEventFailItem(Item: TAbArchiveItem;
  ProcessType: TAbProcessType; ErrorClass: TAbErrorClass; ErrorCode: integer);
begin
  if Assigned(FOnFailItem) then
    FOnFailItem(Self, Item, ProcessType, ErrorClass, ErrorCode);
end;

procedure TCore.ExecEventDwnProcess(DwnFile: downloadInfo);
begin
  if Assigned(FOnDwnProcess) then
    FOnDwnProcess(DwnFile, Self);
end;

procedure TCore.ExecEventDwnEnd(DwnFile: downloadInfo);
begin
  if Assigned(FOnDwnEnd) then
    FOnDwnEnd(DwnFile, Self);
end;

procedure TCore.ExecEventUnarchItem(Item: TAbArchiveItem; Progress: Byte;
  var Abort: boolean);
begin
  if Assigned(FOnUnarchItem) then
    FOnUnarchItem(Self, Item, Progress, Abort);
end;

function TCore.Login: boolean;
var
  DataOnServer: TIdMultiPartFormDataStream;
  HTTPmech: TIdHTTP;
  Response: TStringStream;
  ResultString, cur_str: string;
  TmpOptions: globalOptions;
  counter, len, lines_found: smallint;
begin

  TmpOptions := PrivateGetOptions;
  result := false;
  ResultString := '';

  if (Length(TmpOptions.pOptions.Login) = 0) and
    (Length(TmpOptions.pOptions.Password) = 0) then
    exit;

  DataOnServer := TIdMultiPartFormDataStream.Create;
  DataOnServer.AddFormField('user', string(TmpOptions.pOptions.Login));
  DataOnServer.AddFormField('password', string(TmpOptions.pOptions.Password));
  DataOnServer.AddFormField('version', string(TmpOptions.webOptions.LVER));

  Response := TStringStream.Create('');

  HTTPmech := TIdHTTP.Create(nil);

  result := false;

  try

    HTTPmech.Post(string(TmpOptions.webOptions.Login), DataOnServer, Response);

    if copy(Response.DataString, 1, 11) = 'Old version' then
    begin
      ExecEventOldVer;
      result := false;
      exit
    end;

    if copy(Response.DataString, 1, 9) = 'Bad login' then
    begin
      result := false;
      ExecEventBadLogin();
      exit
    end;

    ResultString := Response.DataString;
    len := Length(ResultString) + 1;
    counter := 1;
    lines_found := 0;
    cur_str := '';

    while counter <> len do
      if ResultString[counter] = ':' then
      begin
        inc(lines_found);

        if lines_found = 1 then
          AuthInfo.GameBuild := StrToInt(cur_str)
        else if lines_found = 2 then
          AuthInfo.Download := cur_str
        else if lines_found = 3 then
          AuthInfo.RealLogin := cur_str
        else if lines_found = 4 then
          AuthInfo.SessionId := cur_str;

        cur_str := '';
        inc(counter)
      end
      else
      begin
        cur_str := cur_str + ResultString[counter];
        inc(counter)
      end;

    if (AuthInfo.RealLogin <> '') and (AuthInfo.SessionId <> '') then
      result := true;

    HTTPmech.Disconnect;
    HTTPmech.free;
    Response.free;
    DataOnServer.free;

  except
    on exception do
    begin
      ExecEventConnectErr;
      result := false;
      HTTPmech.Disconnect;
      HTTPmech.free;
      Response.free;
      DataOnServer.free;
    end;
  end;

  if not result then
    if Length(ResultString) = 0 then
      ExecEventUnknown('ПУСТАЯ СТРОКА')
    else
      ExecEventUnknown(ResultString);

end;

function TCore.DownloadMD5(fname: string): string;
var
  Strm: TMemoryStream;
  HTTPmech: TIdHTTP;
begin

  Strm := TMemoryStream.Create;
  HTTPmech := TIdHTTP.Create(nil);

  result := '';

  try

    HTTPmech.Get(string(PrivateGetOptions.webOptions.Distr) + fname, Strm);

    SetString(result, PChar(Strm.memory), Strm.size);

  except
    on exception do
      result := 'none';
  end;

  Strm.free;
  HTTPmech.free;

end;

function TCore.ValidConfig(Depass, VERSION: string): boolean;
var
  TmpPass: integer;
begin

  result := false;

  if Length(Depass) > 0 then
  begin

    if not TryStrToInt(DeCryptMe(Depass, IntToStr(PassBase)), TmpPass) then
      exit;

    if not TryStrToInt(Decrypt(VERSION, TmpPass), TmpPass) then
      exit;

  end
  else
  begin

    if not TryStrToInt(VERSION, TmpPass) then
      exit;

  end;

  result := true;

end;

function TCore.DownloadConfig: boolean;
var
  Strm: TMemoryStream;
  HTTPmech: TIdHTTP;
  AutoConfigLink: string;
  DownloadOptions: prefabOptions;
begin

  result := false;

  AutoConfigLink := PrivateGetOptions.webOptions.AutoConfig;

  if Length(AutoConfigLink) = 0 then
    exit;

  Strm := TMemoryStream.Create;
  HTTPmech := TIdHTTP.Create(nil);

  try

    HTTPmech.Get(AutoConfigLink, Strm);
    Strm.Position := 0;
    Strm.Read(DownloadOptions, SizeOf(DownloadOptions));

    if not ValidConfig(DownloadOptions.sysOptions.Depass,
      DownloadOptions.webOptions.LVER) then
    begin
      OldLauncherTicket;
      result := false
    end
    else
    begin

      Options.sysOptions.Depass := DownloadOptions.sysOptions.Depass;
      Options.sysOptions.Forbit := DownloadOptions.sysOptions.Forbit;
      Options.webOptions.News := DownloadOptions.webOptions.News;
      Options.webOptions.Login := DownloadOptions.webOptions.Login;
      Options.webOptions.Distr := DownloadOptions.webOptions.Distr;
      Options.webOptions.Distr_list := DownloadOptions.webOptions.Distr_list;
      // Options.webOptions.AutoConfig :=  DownloadOptions.webOptions.AutoConfig;
      Options.webOptions.Reg := DownloadOptions.webOptions.Reg;

      Options.webOptions.LVER := DownloadOptions.webOptions.LVER;

      result := true;

    end;

  except
    on exception do
      result := false;
  end;

  if not result then
    ExecEventConnectErr;

  Strm.free;
  HTTPmech.free;

end;

function TCore.IsNativesWinInstalled: boolean;
var
  TmpOptions: globalOptions;
  dirNative: string;
begin

  TmpOptions := PrivateGetOptions;

  dirNative := TmpOptions.gOptions.Game + 'bin\natives\';

  if (not FileExists(dirNative + 'jinput-dx8.dll')) or
    (not FileExists(dirNative + 'jinput-dx8_64.dll')) or
    (not FileExists(dirNative + 'jinput-raw.dll')) or
    (not FileExists(dirNative + 'jinput-raw_64.dll')) or
    (not FileExists(dirNative + 'lwjgl.dll')) or
    (not FileExists(dirNative + 'lwjgl64.dll')) or
    (not FileExists(dirNative + 'OpenAL32.dll')) or
    (not FileExists(dirNative + 'OpenAL64.dll')) then
    result := false
  else
    result := true;

end;

function TCore.IsGameWinInstalled: boolean;
var
  TmpOptions: globalOptions;
  dirBin: string;
begin

  TmpOptions := PrivateGetOptions;

  dirBin := TmpOptions.gOptions.Game + 'bin\';

  if (not FileExists(dirBin + 'jinput.jar')) or
    (not FileExists(dirBin + 'lwjgl.jar')) or
    (not FileExists(dirBin + 'lwjgl_util.jar')) or
    (not FileExists(dirBin + 'minecraft.jar')) or (not IsNativesWinInstalled)
  then
    result := false
  else
    result := true;

end;

function TCore.NeedToFileUpdate(fname, hash: string): boolean;
begin

  result := true;

  if not FileExists(fname) then
    exit;

  // result := false;

  if hash = 'none' then
    exit;

  // messageBox(0,pChar(GetMD5Hash(fname) + '| ' + hash + ' | '+ fname),'Ошибка', mb_OK);

  if CompareText(trim(GetMD5Hash(fname)), trim(hash)) = 0 then
    result := false
  else
    result := true;

end;

function TCore.DownloadFileList(): boolean;
var
  i: integer;
  FileList: TStringArray;
  TmpOptions: globalOptions;
begin
  result := true;

  setlength(FileList, 0);
  TmpOptions := PrivateGetOptions;

  if Length(TmpOptions.webOptions.Distr_list) = 0 then
  begin
    result := false;
    exit;
  end;

  FileList := Explode(TmpOptions.webOptions.Distr_list, '|');

  for i := 0 to High(FileList) do
    if not DownloadFile(FileList[i]) then
    begin

      result := false;
      exit;

    end;

end;

{

  Умное скачивание файла, со всеми необходимыми проверками подлинности файлов и необходимостью их загрузки

}

function TCore.DownloadFile(fname: string): boolean;
var

  Strm: TMemoryStream;
  HTTPmech: TIdHTTP;
  tmp: string;
  HTTPParams: string;
  TmpOptions: globalOptions;
  AntiFreeze: TIdAntiFreeze;
  zip: boolean;
  cur_mineHash, web_mineHash: string;
begin

  HTTPParams := '';
  TmpOptions := PrivateGetOptions;

  if Length(TmpOptions.gOptions.Game) = 0 then
  begin
    result := false;
    exit;
  end;

  if ExtractFileExt(fname) = '.zip' then
    zip := true
  else
    zip := false;

  {

    Пропуск на скачивание как в оригинальном лаунчере, эти данные могут появиться только после авторизации

  }

  if (Length(AuthInfo.Download) > 0) and (Length(TmpOptions.pOptions.Login) > 0)
  then
    HTTPParams := '?user=' + TmpOptions.pOptions.Login + '&ticket=' +
      AuthInfo.Download;

  Download.name := fname;

  {

    Библиотеки для разных операционных систем. В данной версии только для windows обработка

  }

  if (fname = 'windows_natives.jar') and (IsNativesWinInstalled) then
  begin

    Download.hash := 'none';
    result := true;
    exit;

  end;

  Download.hash := DownloadMD5(fname + '.md5');
  result := true;

  {

    Проверка необходимости скачивания файла

    Так если файл не имеет файл проверки хэша, он скачивается каждый раз.

    Исключение zip, если отсутствует проверка хэша zipа , проверка проходит по запросу хэша minecraft.jar'a

  }

  if (not zip) and (fname <> 'windows_natives.jar') and
    (not NeedToFileUpdate(TmpOptions.gOptions.Game + 'bin\' + fname,
    Download.hash)) then
    exit;

  if (Download.hash <> 'none') and (zip) and
    (not NeedToFileUpdate(RootDir + 'TEMP\' + fname, Download.hash)) then
  begin

    if not ZipUnzip(RootDir, fname, false) then
      result := false
    else
    begin

      Options.gOptions.MineHash :=
        CryptMe(GetMD5Hash(TmpOptions.gOptions.Game + 'bin\minecraft.jar'),
        TmpOptions.sysOptions.Depass);
      SaveOptions;

    end;

    exit;

  end;

  {

    Хэш файл zip'a отсутствует - проверяем по minecraft.jarу
    если на сайте есть хэш minecraft jar - не перекачиваем если все соответствует

  }

  if (Download.hash = 'none') and (zip) then
  begin

    cur_mineHash := GetMD5Hash(TmpOptions.gOptions.Game + 'bin\minecraft.jar');
    { хэш текущего исполняемого файла }
    web_mineHash := DownloadMD5(fname + '.md5');

    Options.gOptions.MineHash := CryptMe(web_mineHash,
      TmpOptions.sysOptions.Depass); { хэш с сайта }
    SaveOptions;

    if CompareText(trim(web_mineHash), trim(cur_mineHash)) = 0 then
      exit;

  end;

  tmp := RootDir;

  // ForceDirectories
  if not DirectoryExists(tmp + 'TEMP\') then
    CreateDirectory(PWideChar(tmp + 'TEMP\'), nil);
  if not DirectoryExists(TmpOptions.gOptions.Game) then
    ForceDirectories(TmpOptions.gOptions.Game);

  Strm := TMemoryStream.Create;
  HTTPmech := TIdHTTP.Create(nil);
  AntiFreeze := TIdAntiFreeze.Create(nil);

  try

    HTTPmech.OnWork := HTTPmechWork;
    HTTPmech.OnWorkBegin := HTTPmechWorkBegin;
    HTTPmech.OnWorkEnd := HTTPmechWorkEnd;

    AntiFreeze.Active := true;

    HTTPmech.Get(TmpOptions.webOptions.Distr + fname + HTTPParams, Strm);

    Strm.SaveToFile(tmp + 'TEMP\' + fname);

    result := true

  except
    on exception do
      result := false;
  end;

  {

    Обработка скачанного файла

  }

  if result = true then
  begin

    if fname = 'windows_natives.jar' then
      ZipUnzip(tmp, fname, true)
    else if zip then
    begin

      if not ZipUnzip(tmp, fname, false) then
        result := false
      else
      begin

        Options.gOptions.MineHash :=
          CryptMe(GetMD5Hash(TmpOptions.gOptions.Game + 'bin\minecraft.jar'),
          TmpOptions.sysOptions.Depass);
        SaveOptions;

      end;

    end
    else
    begin

      if not DirectoryExists(TmpOptions.gOptions.Game + 'bin\') then
        ForceDirectories(TmpOptions.gOptions.Game + 'bin\');

      if fname = 'minecraft.jar' then
      begin

        Options.gOptions.MineHash := CryptMe(Download.hash,
          TmpOptions.sysOptions.Depass);
        SaveOptions;

      end;

      if not CopyFile(PChar(tmp + 'TEMP\' + fname),
        PChar(TmpOptions.gOptions.Game + 'bin\' + fname), false) then
        result := false;

      DeleteFile(tmp + 'TEMP\' + fname);

    end;

  end;

  {

    Clean Up

  }

  Strm.free;
  HTTPmech.free;
  AntiFreeze.free;

end;

function TCore.ZipUnzip(RootDir, fname: string; delete: boolean): boolean;
var
  ZipModule: TAbUnZipper;
  GameDir: string;
begin

  result := true;

  UnzipFailTrigger := false;
  GameDir := PrivateGetOptions.gOptions.Game;

  ZipModule := TAbUnZipper.Create(nil);
  ZipModule.OnArchiveItemProgress := UnzipItemWork;
  ZipModule.OnProcessItemFailure := UnzipItemFail;
  ZipModule.ExtractOptions := [eoCreateDirs, eoRestorePath];

  with ZipModule do
  begin

    BaseDirectory := GameDir;

    if fname = 'windows_natives.jar' then
      BaseDirectory := GameDir + 'bin\natives\';

    if not DirectoryExists(BaseDirectory) then
      ForceDirectories(BaseDirectory);

    FileName := RootDir + 'TEMP\' + fname;
    ExtractFiles('*.*');

  end;

  if UnzipFailTrigger then
    result := false;

  if (result) and (fname = 'client.zip') and
    (not FileExists(GameDir + 'bin\minecraft.jar')) then
    result := false;

  FreeAndNil(ZipModule);

  if delete then
    DeleteFile(RootDir + 'TEMP\' + fname);

end;

procedure TCore.UnzipItemWork(Sender: TObject; Item: TAbArchiveItem;
  Progress: Byte; var Abort: boolean);
begin
  ExecEventUnarchItem(Item, Progress, Abort);
end;

procedure TCore.UnzipItemFail(Sender: TObject; Item: TAbArchiveItem;
  ProcessType: TAbProcessType; ErrorClass: TAbErrorClass; ErrorCode: integer);
begin
  UnzipFailTrigger := false;
  ExecEventFailItem(Item, ProcessType, ErrorClass, ErrorCode);
end;

procedure TCore.HTTPmechWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  Download.currentsize := AWorkCount;
  ExecEventDwnProcess(Download);
end;

procedure TCore.HTTPmechWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  Download.currentsize := 0;
  Download.size := AWorkCountMax;
end;

procedure TCore.HTTPmechWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
begin
  Download.currentsize := Download.size;
  ExecEventDwnEnd(Download);
end;

function TCore.LoadOptions: boolean;
var
  FOptions: File of globalOptions;
  OptionsFile: string;
  TmpOptions: globalOptions;
begin

  OptionsFile := RootDir + 'options.cfg';

  if FileExists(OptionsFile) = false then
  begin
    result := false;
    exit
  end;

  AssignFile(FOptions, OptionsFile);
  Reset(FOptions);

  while (not EOF(FOptions)) do
  begin

    if IOResult > 0 then
    begin
      result := false;

      exit
    end;

    Read(FOptions, TmpOptions);

  end;

  if not ValidConfig(TmpOptions.sysOptions.Depass, TmpOptions.webOptions.LVER)
  then
    result := false
  else
  begin
    result := true;
    Options := TmpOptions;
  end;

  CloseFile(FOptions);

end;

procedure TCore.SaveAuthOptions(fname: string);
var
  FOptions: File of prefabOptions;
  PrefabSet: prefabOptions;
begin

  PrefabSet.sysOptions.Depass := Options.sysOptions.Depass;
  PrefabSet.sysOptions.Forbit := Options.sysOptions.Forbit;
  PrefabSet.webOptions.News := Options.webOptions.News;
  PrefabSet.webOptions.Login := Options.webOptions.Login;
  PrefabSet.webOptions.Distr := Options.webOptions.Distr;
  PrefabSet.webOptions.Distr_list := Options.webOptions.Distr_list;
  PrefabSet.webOptions.Reg := Options.webOptions.Reg;
  PrefabSet.webOptions.LVER := Options.webOptions.LVER;

  AssignFile(FOptions, fname);
  Rewrite(FOptions);
  Write(FOptions, PrefabSet);
  CloseFile(FOptions);

end;

procedure TCore.OldLauncherTicket;
begin
  ExecEventOldLauncher();
end;

function TCore.LoadAuthOptions(fname: string): boolean;
var
  FOptions: File of prefabOptions;
  PrefabSet: prefabOptions;
begin

  result := true;

  if FileExists(fname) = false then
  begin
    result := false;
    exit
  end;

  AssignFile(FOptions, fname);
  Reset(FOptions);

  while (not EOF(FOptions)) do
  begin

    if IOResult > 0 then
    begin
      result := false;
      exit
    end;

    Read(FOptions, PrefabSet);
  end;

  if not ValidConfig(PrefabSet.sysOptions.Depass, PrefabSet.webOptions.LVER)
  then
  begin
    OldLauncherTicket;
    result := false;
    CloseFile(FOptions);
    exit;
  end;

  CloseFile(FOptions);

  Options.sysOptions.Depass := PrefabSet.sysOptions.Depass;
  Options.sysOptions.Forbit := PrefabSet.sysOptions.Forbit;
  Options.webOptions.News := PrefabSet.webOptions.News;
  Options.webOptions.Login := PrefabSet.webOptions.Login;
  Options.webOptions.Distr := PrefabSet.webOptions.Distr;
  Options.webOptions.Distr_list := PrefabSet.webOptions.Distr_list;
  Options.webOptions.Reg := PrefabSet.webOptions.Reg;
  Options.webOptions.LVER := PrefabSet.webOptions.LVER;

end;

procedure TCore.SaveOptions;
var
  FOptions: File of globalOptions;
  OptionsDir: string;
begin

  OptionsDir := RootDir;

  if not DirectoryExists(OptionsDir) then
    CreateDir(OptionsDir);

  AssignFile(FOptions, OptionsDir + 'options.cfg');
  Rewrite(FOptions);
  Write(FOptions, Options);
  CloseFile(FOptions);

end;

function TCore.PrivateGetOptions: globalOptions;
var
  tempPass: Word;
  decOptions: globalOptions;
begin

  decOptions := Options;

  if Length(Options.sysOptions.Depass) > 0 then
  begin

    tempPass := StrToInt(Decrypt(decOptions.sysOptions.Depass, PassBase));

    decOptions.pOptions.Login := Decrypt(Options.pOptions.Login, tempPass);
    decOptions.pOptions.Password := Decrypt(Options.pOptions.Password,
      tempPass);
    decOptions.webOptions.Login := Decrypt(Options.webOptions.Login, tempPass);
    decOptions.webOptions.Distr := Decrypt(Options.webOptions.Distr, tempPass);
    decOptions.webOptions.Distr_list := Decrypt(Options.webOptions.Distr_list,
      tempPass);
    decOptions.webOptions.LVER := Decrypt(Options.webOptions.LVER, tempPass);
    decOptions.gOptions.MineHash := Decrypt(Options.gOptions.MineHash,
      tempPass);
    decOptions.sysOptions.Depass := IntToStr(tempPass);

  end;

  result := decOptions;
end;

{

  Вывод опций во внешних модулях

}

function TCore.GetOptions: globalOptions;
var
  decOptions: globalOptions;
begin

  decOptions := PrivateGetOptions;

  if decOptions.sysOptions.Forbit then
  begin

    decOptions.webOptions.Login := 'hidden';
    decOptions.webOptions.Distr := 'hidden';
    decOptions.webOptions.Distr_list := 'hidden';
    decOptions.webOptions.LVER := 'hidden';
    decOptions.gOptions.MineHash := 'hidden';
    decOptions.sysOptions.Depass := 'hidden';

  end;

  result := decOptions;

end;

{

  PrivateSetOptions

  Приватный метод записи новых настроек

  Подразумевает полную готовность входных данных к записи

  IN - в зависимости от настроек шифрования

}

procedure TCore.PrivateSetOptions(newOptions: globalOptions);
begin

  Options := newOptions;
  SaveOptions;

end;

{
  Записка:
  gOptions.Java меняется в открытом виде в функции FindJava
  т.е. шифрование запрещено
}

procedure TCore.SetOptions(newOptions: globalOptions);
var
  tempPass: Word;
begin
  // возвращается hidden если forbitt
  // if (Length(newOptions.sysOptions.Depass) > 0) and (not TryStrToInt(newOptions.sysOptions.Depass, Validator))
  // then begin messageBox(0,pChar('Код шифрования должен быть задан числом.'),'Ошибка', mb_OK); exit; end;

  // запретить извемять forbit
  // post запрос клинит если есть русские символы. проверять входные символы pregmath
  // не сраюатывает запуск java 1g 2g

  {

    SetOptions

    Обработка входных параметров посылаемых из формы.

    IN - не шифрованы
    OUT - шифрованы

    Если системные поля менять запрещено, то перезаписываем текущими

  }

  if Options.sysOptions.Forbit then
  begin

    newOptions.webOptions.Login := Options.webOptions.Login;
    newOptions.webOptions.Distr := Options.webOptions.Distr;
    newOptions.webOptions.Distr_list := Options.webOptions.Distr_list;
    newOptions.webOptions.LVER := Options.webOptions.LVER;
    newOptions.gOptions.MineHash := Options.gOptions.MineHash;
    newOptions.sysOptions.Depass := Options.sysOptions.Depass;

    newOptions.sysOptions.Forbit := true;

  end;

  {

    Если добавился ключ шифрования, то шифруем важные данные

  }

  if Length(newOptions.sysOptions.Depass) > 0 then
  begin

    if Options.sysOptions.Forbit then

      tempPass := StrToInt(Decrypt(newOptions.sysOptions.Depass, PassBase))

    else
    begin

      tempPass := StrToInt(newOptions.sysOptions.Depass);
      newOptions.sysOptions.Depass := Encrypt(newOptions.sysOptions.Depass,
        PassBase);

    end;

    newOptions.pOptions.Login := Encrypt(newOptions.pOptions.Login, tempPass);
    newOptions.pOptions.Password := Encrypt(newOptions.pOptions.Password,
      tempPass);

    if not Options.sysOptions.Forbit then
    begin

      newOptions.webOptions.Login := Encrypt(newOptions.webOptions.Login,
        tempPass);
      newOptions.webOptions.Distr := Encrypt(newOptions.webOptions.Distr,
        tempPass);
      newOptions.webOptions.Distr_list :=
        Encrypt(newOptions.webOptions.Distr_list, tempPass);
      newOptions.webOptions.LVER := Encrypt(newOptions.webOptions.LVER,
        tempPass);
      newOptions.gOptions.MineHash := Encrypt(newOptions.gOptions.MineHash,
        tempPass);

    end;

  end;

  {

    Заменяем основные настройки, сохраняем в файл

  }

  PrivateSetOptions(newOptions);

end;

function TCore.DeCryptMe(somestring: string; pass: string): string;
var
  tempPass: Word;
begin

  if Length(pass) > 0 then
  begin

    tempPass := StrToInt(pass);
    result := Decrypt(somestring, tempPass)

  end
  else
    result := somestring;

end;

function TCore.CryptMe(somestring: string; pass: string): string;
var
  tempPass: Word;
begin

  if Length(pass) > 0 then
  begin

    tempPass := StrToInt(pass);
    result := Encrypt(somestring, tempPass);

  end
  else
    result := somestring;

end;

function TCore.GetSysDir(direcoty: smallint): string;
var
  PathIDList: PItemIDList;
  FBuf: array [0 .. MAX_PATH] of Char;
begin

  setlength(result, MAX_PATH);
  // Application.Handle
  SHGetSpecialFolderLocation(0, direcoty, PathIDList);

  if (PathIDList <> nil) then
  begin
    SHGetPathFromIDList(PathIDList, @FBuf[0]);
    result := string(FBuf)
  end
  else
    result := '';

end;

end.
