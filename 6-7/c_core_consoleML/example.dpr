program Project1;
{$APPTYPE CONSOLE}

uses
  windows,AbArcTyp, SysUtils,
  c_menu in 'c_menu.pas',
  c_core in 'c_core.pas';

type
  TEventHandlers = class // create a dummy class
     procedure BadLogin();
     procedure UnknownErr(Reciev : string);
     procedure OldVer();
     procedure OldLauncher();
     procedure ConnectErr();
     procedure Downloading(DwnFile: downloadInfo; Sender:TObject);
     procedure Unzip(Sender : TObject; Item : TAbArchiveItem; Progress : Byte; var Abort : Boolean);
   end;
   
var
  console : TConsoleOutput;
  typed : string;
  newOptions : globalOptions;
  Core : TCore;
  EvHandler:TEventHandlers;

{
Обработка событий. Наглядней в виндовых примерах
}

procedure TEventHandlers.BadLogin();
begin
 console.ConsoleLongMessage(3,14,60,'Пользователь не существует или пароль введен неверно');
 readln;
end;

procedure TEventHandlers.UnknownErr(Reciev : string);
begin
 console.ConsoleLongMessage(3,14,60,'Сервер вернул некорректный ответ: '+ Reciev);
 readln;
end;

procedure TEventHandlers.OldVer();
begin
 console.ConsoleLongMessage(3,14,60,'Версия клиент не соответствует версии требуемой сервером');
 readln;
end;

procedure TEventHandlers.OldLauncher();
begin
 console.ConsoleLongMessage(3,14,60,'Лаунчер устарел');
 readln;
end;

procedure TEventHandlers.ConnectErr();
begin
 console.ConsoleLongMessage(3,14,60,'Сервер авторизации недоступен');
 readln;
end;

procedure TEventHandlers.Downloading(DwnFile: downloadInfo; Sender:TObject);
var
 total, cur : integer;
begin
cur := DwnFile.currentsize;
total := DwnFile.size;

  console.ConsoleLongMessage(3,14,60,'[Загрузка обновлений] [' + IntToStr(round((cur/total)*100)) + '%] Файл: ' + DwnFile.name);
end;

procedure TEventHandlers.Unzip(Sender : TObject; Item : TAbArchiveItem; Progress : Byte; var Abort : Boolean);
var
  fname : string;
begin

fname := ExtractFileName(StringReplace(Item.FileName,'/','\',[rfReplaceAll]));

if Length(fname) > 0 then
 console.ConsoleLongMessage(3,14,60,'[Синхронизация] Файл: ' + fname); 
end;

begin

 // Create(_Имя_папки_лаунчера_, _Папка_с_игрой_)
 // Папки создаются в AppData\Application Data конкретного пользователя

 Core := TCore.Create('ConsoleLauncher', 'TWEBMCR'); // создаем экземпляр объекта "Ядро"
 {
  скачиваем файл настроек. По умолчанию craft.catface.ru... все прописано в c_core

  при скачивании файла настроек синхронизируются только ссылки
  и некоторые данные необходимые для подключения
  аналогично см. что прописано в c_core
 }

  Core.DownloadConfig;

 {
  Добавляем обработку событий
 }
  Core.OnUnarchItem      := EvHandler.Unzip;       // Разархивирования zip архива
  Core.OnDownloadProcess := EvHandler.Downloading; // Процесс загрузки файла
  Core.OnUnknown         := EvHandler.UnknownErr;  // Неизвестный ответ от сервера
  Core.OnOldLauncher     := EvHandler.OldLauncher; // Протокол лаунчера устарел ( ошибка возникает при неудачном чтении файла автонастроек \ настроек )
  Core.OnOldVer          := EvHandler.OldVer;      // Ответ сервера - Old version
  Core.OnConnectErr      := EvHandler.ConnectErr;  // Сервер авторизации недоступен
  Core.OnBadLogin        := EvHandler.BadLogin;    // Ответ сервера - Bad Login

 console := TConsoleOutput.Create;   // это мой класс для работы с консолью, не обращаем внимания >_>
 console.ConsoleInit;


 newOptions := Core.currentOptions; // запрашиваем у ядра текущие настройки

 console.ConsoleLine(3,5,'Сервер автонастройки: ', 40);
 console.ConsoleLine(3,6,newOptions.webOptions.AutoConfig, 40);

 console.ConsoleLine(3,7,'Введите имя: ', 14);
 console.CursorPos(18,7); readln(typed);

 newOptions.pOptions.Login := typed;  // изменяем имя пользователя
 
 console.ConsoleLine(3,8,'Введите пароль: ', 14);
 console.CursorPos(20,8); readln(typed);

 newOptions.pOptions.Password := typed;  // изменяем пароль пользователя

 Core.currentOptions := newOptions; // передаем измененные настройки обратно

  if Core.Login then begin // пробуем получить данные для входа на сервер ( идентификатор сессии )
     if Core.DownloadFileList() then Core.Play; // скачиваем файлы, указанные в файле настроек ( по умолчанию задается список файлов из c_core ), если все прошло успешно, запускаем игру
  end;
end.
