unit memory;

interface

function isbit(data:longint; bit:integer):boolean;
function setbit(data:longint; bit:integer; turn:boolean):longint;
function bitcpy(dest:longint; src:longint; first:integer; last:integer):longint;
procedure swapBits(var left:longint; var right:longint; index:integer);
procedure memcpy(dest:pointer; src:pointer; len:integer);
procedure memset(dest: pointer; value:byte; numBytes:Integer);

implementation

function isbit(data:longint; bit:integer):boolean; {bit=0..(8*sizeof(integer)-1)}
var
    tmp:longint;
begin
    tmp:=1;
    tmp:= (tmp shl bit);
    tmp:= (tmp and data);
    if tmp=0 then
        IsBit:=false
    else
        IsBit:=true;
end;

{turn one bit on/off}
function setbit(data:longint; bit:integer; turn:boolean):longint;
var
    tmp:longint;
begin
    tmp:=1;
    tmp:= (tmp shl bit);
    if(turn) then
        SetBit:=(data or tmp)
    else
        SetBit:= data and (not tmp);
end;

{Copying a set of bits from src to dest. Position of first and last has to be from 0 to (8*sizeof(longint)-1)}
function bitcpy(dest:longint; src:longint; first:integer; last:integer):longint;
var
    tmp:longint;
    cnt:integer;
begin
    {argument check must be there}
    cnt:=first;
    tmp:=dest;
    repeat
        begin
            tmp:=SetBit(tmp, cnt, IsBit(src, cnt));
            inc(cnt);
        end
    until (cnt = last);
    BitCpy:=tmp;
end;

{c-style memory copying}
procedure memcpy(dest:pointer; src:pointer; len:integer);
var
    d,s:^byte;
begin
    d:=dest;
    s:=src;
    while(len>0) do
    begin
        d^:=s^;
        inc(s);
        inc(d);
        dec(len);
    end;
end;

{c-style memset function}
procedure memset(dest: pointer; value:byte; numBytes:Integer);
var
	i: Integer;
	p: ^byte;
begin
	p:=dest;
	for i:=0 to numBytes do
	begin
		p^:=value;
		inc(p);
	end;
end;

procedure swapBits(var left:longint; var right:longint; index:integer);
var
	isLeft, isRight: boolean;
begin
	isLeft:=isBit(right, index);
	isRight:=isBit(left,index);
	left:=setBit(left, index, isLeft);
	right:=setBit(right, index, isRight);
end;

end.

