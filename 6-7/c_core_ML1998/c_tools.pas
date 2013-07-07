unit c_tools;

interface

uses
  windows;
  
type

 TByteArray = array of array of byte;
 
function CompareBytes(T1 : array of byte; T2 : array of byte) : boolean;
procedure WriteBytes(var InsertIN : array of byte; Bytes : array of byte; num : integer = -1; from : integer = 0);
function SpecExplode(Text : array of byte ; Delimiter: array of byte) : TByteArray;

implementation

function CompareBytes(T1 : array of byte; T2 : array of byte) : boolean;
var
  i : integer;
begin

   result := false;

   if High(T1) <> High(T2) then exit;

   for i:=0 to High(T1) do
     if T1[i] <> T2[i] then exit;

   result := true;

end;

procedure WriteBytes(var InsertIN : array of byte; Bytes : array of byte; num : integer = -1; from : integer = 0);
var
  i : integer;
begin

  if (num = -1) or (num > High(Bytes)) then num := High(Bytes);
  if (from >= High(Bytes)) then exit;
  for i:=0 to num do InsertIN[i] := Bytes[i+from];

end;

function SpecExplode(Text : array of byte ; Delimiter: array of byte) : TByteArray;
var
  i,tmp,
  str_key       : integer;
  cur_bytes     : array of byte;
  compare_bytes : array of byte;
  compare : boolean;
begin
    str_key := 0;
    setlength(result,0);
    setlength(compare_bytes,Length(Delimiter));

    i := 0;

    while i <= High(Text) do begin

       compare := false;

       if Delimiter[0] = Text[i] then begin
        setlength(compare_bytes,0);
        setlength(compare_bytes,Length(Delimiter));

        WriteBytes(compare_bytes,Text,Length(Delimiter),i);
        if CompareBytes(compare_bytes,Delimiter) then compare := true;
       end;

        if not compare then begin

              tmp := Length(cur_bytes);
              setlength(cur_bytes,tmp+1);
              cur_bytes[tmp] := Text[i];

           if i = High(Text) then begin

                setlength(result,str_key+1);
                setlength(result[str_key],Length(cur_bytes));
                WriteBytes(result[str_key],cur_bytes);

                inc(i,Length(compare_bytes)-1);
                inc(str_key);

                setlength(cur_bytes,0);

           end;

        end
        else begin

                setlength(result,str_key+1);
                setlength(result[str_key],Length(cur_bytes));
                WriteBytes(result[str_key],cur_bytes);

                inc(i,Length(compare_bytes)-1);
                inc(str_key);

                setlength(cur_bytes,0);

             end;

        inc(i);
    end;
end;

end. 