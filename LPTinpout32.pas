unit LPTinpout32;

interface

function LptChangeOutput: Boolean; // проводится загрузка текущего состояние регистра OUTPUT, на выходе TRUE в случае нового значения
function LptChangeInput: Boolean;  // проводится загрузка текущего состояние регистра INPUT, на выходе TRUE в случае нового значения
function LptChangeInOut: Boolean;  // проводится загрузка текущего состояние регистра IN/OUT, на выходе TRUE в случае нового значения

function LptOutput: Byte; // значение регистра OUTPUT
function LptInput: Byte;  // значение регистра INPUT
function LptInOut: Byte;  // значение регистра IN/OUT

procedure LptSetOutput(newValue: Byte); // установка нового значения регистра OUTPUT
procedure LptSetInOut(newValue: Byte);  // установка нового значения регистра IN/OUT

function LptGetPin(PinNumb: Byte): Boolean;        // есть ли напряжение на ножке PinNumb
procedure LptSetPin(PinNumb: Byte; Volt: Boolean); // устанавливает/снимает напряжение на ножке PinNumb
  
implementation

function Inp32(PortAdr: Word): Byte; stdcall; external 'inpout32.dll';
function Out32(PortAdr: Word; Data: Byte): Byte; stdcall; external 'inpout32.dll';

type
  TLPTrec = record      // ЗАПИСЬ ТАБЛИЦЫ ПИНОВ ДЛЯ LPT ПОРТА
    RegNumb : Byte;     // номер регистра (0 - регистр ДАННЫХ OUTPUT, 1 - регистр СОСТОЯНИЯ INPUT, 2 - регистр КОНТРОЛЯ IN/OUT)
    BitNumb : Byte;     // номер бита в регистре
    Inversed: Boolean;  // инверсия бита (некоторые пины работают наоборот)
  end;

const
  LPTPINTABLE: array [1..17] of TLPTrec = (     // ТАБЛИЦА ПЕРЕВОДА ПИНОВ LPT ПОРТА
    (RegNumb: 2; BitNumb: 0; Inversed: True),   // пин 1
    (RegNumb: 0; BitNumb: 0; Inversed: False),  // пин 2
    (RegNumb: 0; BitNumb: 1; Inversed: False),  // пин 3
    (RegNumb: 0; BitNumb: 2; Inversed: False),  // пин 4
    (RegNumb: 0; BitNumb: 3; Inversed: False),  // пин 5
    (RegNumb: 0; BitNumb: 4; Inversed: False),  // пин 6
    (RegNumb: 0; BitNumb: 5; Inversed: False),  // пин 7
    (RegNumb: 0; BitNumb: 6; Inversed: False),  // пин 8
    (RegNumb: 0; BitNumb: 7; Inversed: False),  // пин 9
    (RegNumb: 1; BitNumb: 6; Inversed: False),  // пин 10
    (RegNumb: 1; BitNumb: 7; Inversed: True),   // пин 11
    (RegNumb: 1; BitNumb: 5; Inversed: False),  // пин 12
    (RegNumb: 1; BitNumb: 4; Inversed: False),  // пин 13
    (RegNumb: 2; BitNumb: 1; Inversed: True),   // пин 14
    (RegNumb: 1; BitNumb: 3; Inversed: False),  // пин 15
    (RegNumb: 2; BitNumb: 2; Inversed: False),  // пин 16
    (RegNumb: 2; BitNumb: 3; Inversed: True));  // пин 17

  ADDRREGLPT: array [0..2] of Integer = (888,889,890(* $378, $379, $37A*)); // адреса регистров OUTPUT, INPUT, IN/OUT
  //ADDRREGLPT: array [0..2] of Integer = (51200,51201,51202(* $378, $379, $37A*)); // адреса регистров OUTPUT, INPUT, IN/OUT

var
  LPTREGVALUE: array [0..2] of Byte; // текущие загруженные значения регистров LPT порта (0-OUTPUT, 1-INPUT, 2-INOUT)

function LoadLptReg(NomReg: Byte): Boolean;
var
  NewVal: Byte;
begin
  NewVal := Inp32(ADDRREGLPT[NomReg]);
  Result := NewVal <> LPTREGVALUE[NomReg];
  if Result then LPTREGVALUE[NomReg] := NewVal;
end;

function LptChangeOutput: Boolean; // проводится загрузка текущего состояние регистра OUTPUT, на выходе TRUE в случае нового значения
begin
  Result := LoadLptReg(0);
end;

function LptChangeInput: Boolean;  // проводится загрузка текущего состояние регистра INPUT, на выходе TRUE в случае нового значения
begin
  Result := LoadLptReg(1);
end;

function LptChangeInOut: Boolean;  // проводится загрузка текущего состояние регистра IN/OUT, на выходе TRUE в случае нового значения
begin
  Result := LoadLptReg(2);
end;

function LptOutput: Byte; // значение регистра OUTPUT
begin
  Result := LPTREGVALUE[0];
end;

function LptInput: Byte;  // значение регистра INPUT
begin
  Result := LPTREGVALUE[1];
end;

function LptInOut: Byte;  // значение регистра IN/OUT
begin
  Result := LPTREGVALUE[2];
end;

procedure SetValueToRegLpt(NomReg, RegValue: Byte);
begin
  LPTREGVALUE[NomReg] := Out32(ADDRREGLPT[NomReg], RegValue);
end;

procedure LptSetOutput(newValue: Byte); // установка нового значения регистра OUTPUT
begin
  SetValueToRegLpt(0, newValue);
end;

procedure LptSetInOut(newValue: Byte);  // установка нового значения регистра IN/OUT
begin
  SetValueToRegLpt(2, newValue);
end;

function GetBit(Value: Byte; BitNum: Byte): Boolean;
begin
  Result := ((Value shr BitNum) and 1) = 1
end;

function LptGetPin(PinNumb: Byte): Boolean;        // есть ли напряжение на ножке PinNumb
begin
  with LPTPINTABLE[PinNumb] do 
    begin
      Result := GetBit(LPTREGVALUE[RegNumb], BitNumb);
      if Inversed then Result := not Result;
    end;
end;

procedure SetBit(var Value: Byte; NumBit: Byte; fSet: Boolean);
begin
   if fset then Value := Value or (1 shl NumBit) else
   Value := Value and not (1 shl NumBit)
end;

procedure LptSetPin(PinNumb: Byte; Volt: Boolean); // устанавливает/снимает напряжение на ножке PinNumb
begin
  with LPTPINTABLE[PinNumb] do 
    begin
      if Inversed then Volt := not Volt;
      SetBit(LPTREGVALUE[RegNumb], BitNumb, Volt);
      Out32(ADDRREGLPT[RegNumb], LPTREGVALUE[RegNumb]);
    end;
end;

var
  i: Integer;
    
initialization
                                                                         ;
for i := 0 to 2 do LoadLptReg(i); // загрузим текущие значения регистров LPT порта

finalization
    
end.
