unit c_query;

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

uses windows,
     winSock;

type
  TStringArray = array of string;

function MQuery(HostStr: string;Port : Word): TStringArray;
function Explode(Text, Delimiter: string) : TStringArray;
procedure SocketInit;
procedure SocketEnd;

implementation

var
  FWSData     : TWSAData;
  //SocketsPool : array of TSocket;

function UTF16toString(source: array of char): String;
var i:integer;
    c:Char;
    s:String;
begin

   s := '';

   for i:=0 to High(source) do begin

      c := source[i];

      if c <> #0 then s := s + char(Integer(c));

   end;

   result := s;

end;

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

procedure SocketInit;
begin
  WSAStartup($202, FWSData);
end;

procedure SocketEnd;
begin
 WSACleanup;
end;

function MQuery(HostStr: string; Port : Word): TStringArray;
var

FAdrr     : TSockAddrIn;
FTimeout  : TTimeVal;
FHostname : PHostEnt;
FSocket   : TSocket;

Hash      : PAnsiChar;
buffer    : array[0..256] of char;
OutStr    : string;
cntread   : integer;

trigger   : bool;
Fds       : TFDSet;
rc        : integer;
begin

 setlength(result,0);

 rc := -1;

 FHostname := GetHostByName(PChar(HostStr));

 if FHostname = nil then exit;

 FAdrr.sin_family := AF_INET;
 FAdrr.sin_port := htons(Port);
 FAdrr.sin_addr := PInAddr(FHostname^.h_addr^)^;

 //FAdrr.sin_addr.S_addr :=  inet_addr(Host);

 FSocket := Socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

 if FSocket=INVALID_SOCKET then begin CloseSocket(FSocket); exit; end;

 //SetSockOpt(FSocket, SOL_SOCKET, SO_RCVTIMEO, @FTimeout, SizeOf(TTimeVal));

 trigger := true;
 if ioctlsocket(FSocket, FIONBIO, integer(trigger)) <> 0 then begin CloseSocket(FSocket); exit; end;

 if connect(FSocket, FAdrr, SizeOf(FAdrr)) = SOCKET_ERROR then begin
     if WSAGetLastError=WSAEWOULDBLOCK then begin
     
      FD_ZERO(Fds);
      FD_SET(FSocket,Fds);
      FTimeout.tv_sec:=2;
      FTimeout.tv_usec:=0;
      
      rc := select(0, nil, @Fds, nil, @FTimeout);
     end;
 end
 else begin CloseSocket(FSocket); exit; end;

 trigger := false;
 if (rc = 0) or (ioctlsocket(FSocket, FIONBIO, integer(trigger)) <> 0) then begin CloseSocket(FSocket); exit; end;

 Hash := Char($FE);

 Send(FSocket, Hash^, 1{StrLen(Hash)}, 0);

 FillChar(buffer, SizeOf(buffer), 0);

     cntread := Recv(FSocket, buffer, 256, 0);

     if (cntread > 0) then begin

         OutStr := UTF16toString(buffer);

         if Length(OutStr) > 3 then begin

                 Delete(OutStr, 1, 2);
                 result := Explode(OutStr, Char($A7));

         end;

         if Length(result) <> 3 then begin   setlength(result,0); exit; end;

      end;

  CloseSocket(FSocket);

end;

end. 