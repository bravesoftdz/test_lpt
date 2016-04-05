unit LPTinpout32;

interface

function LptChangeOutput: Boolean; // ���������� �������� �������� ��������� �������� OUTPUT, �� ������ TRUE � ������ ������ ��������
function LptChangeInput: Boolean;  // ���������� �������� �������� ��������� �������� INPUT, �� ������ TRUE � ������ ������ ��������
function LptChangeInOut: Boolean;  // ���������� �������� �������� ��������� �������� IN/OUT, �� ������ TRUE � ������ ������ ��������

function LptOutput: Byte; // �������� �������� OUTPUT
function LptInput: Byte;  // �������� �������� INPUT
function LptInOut: Byte;  // �������� �������� IN/OUT

procedure LptSetOutput(newValue: Byte); // ��������� ������ �������� �������� OUTPUT
procedure LptSetInOut(newValue: Byte);  // ��������� ������ �������� �������� IN/OUT

function LptGetPin(PinNumb: Byte): Boolean;        // ���� �� ���������� �� ����� PinNumb
procedure LptSetPin(PinNumb: Byte; Volt: Boolean); // �������������/������� ���������� �� ����� PinNumb
  
implementation

function Inp32(PortAdr: Word): Byte; stdcall; external 'inpout32.dll';
function Out32(PortAdr: Word; Data: Byte): Byte; stdcall; external 'inpout32.dll';

type
  TLPTrec = record      // ������ ������� ����� ��� LPT �����
    RegNumb : Byte;     // ����� �������� (0 - ������� ������ OUTPUT, 1 - ������� ��������� INPUT, 2 - ������� �������� IN/OUT)
    BitNumb : Byte;     // ����� ���� � ��������
    Inversed: Boolean;  // �������� ���� (��������� ���� �������� ��������)
  end;

const
  LPTPINTABLE: array [1..17] of TLPTrec = (     // ������� �������� ����� LPT �����
    (RegNumb: 2; BitNumb: 0; Inversed: True),   // ��� 1
    (RegNumb: 0; BitNumb: 0; Inversed: False),  // ��� 2
    (RegNumb: 0; BitNumb: 1; Inversed: False),  // ��� 3
    (RegNumb: 0; BitNumb: 2; Inversed: False),  // ��� 4
    (RegNumb: 0; BitNumb: 3; Inversed: False),  // ��� 5
    (RegNumb: 0; BitNumb: 4; Inversed: False),  // ��� 6
    (RegNumb: 0; BitNumb: 5; Inversed: False),  // ��� 7
    (RegNumb: 0; BitNumb: 6; Inversed: False),  // ��� 8
    (RegNumb: 0; BitNumb: 7; Inversed: False),  // ��� 9
    (RegNumb: 1; BitNumb: 6; Inversed: False),  // ��� 10
    (RegNumb: 1; BitNumb: 7; Inversed: True),   // ��� 11
    (RegNumb: 1; BitNumb: 5; Inversed: False),  // ��� 12
    (RegNumb: 1; BitNumb: 4; Inversed: False),  // ��� 13
    (RegNumb: 2; BitNumb: 1; Inversed: True),   // ��� 14
    (RegNumb: 1; BitNumb: 3; Inversed: False),  // ��� 15
    (RegNumb: 2; BitNumb: 2; Inversed: False),  // ��� 16
    (RegNumb: 2; BitNumb: 3; Inversed: True));  // ��� 17

  ADDRREGLPT: array [0..2] of Integer = (888,889,890(* $378, $379, $37A*)); // ������ ��������� OUTPUT, INPUT, IN/OUT
  //ADDRREGLPT: array [0..2] of Integer = (51200,51201,51202(* $378, $379, $37A*)); // ������ ��������� OUTPUT, INPUT, IN/OUT

var
  LPTREGVALUE: array [0..2] of Byte; // ������� ����������� �������� ��������� LPT ����� (0-OUTPUT, 1-INPUT, 2-INOUT)

function LoadLptReg(NomReg: Byte): Boolean;
var
  NewVal: Byte;
begin
  NewVal := Inp32(ADDRREGLPT[NomReg]);
  Result := NewVal <> LPTREGVALUE[NomReg];
  if Result then LPTREGVALUE[NomReg] := NewVal;
end;

function LptChangeOutput: Boolean; // ���������� �������� �������� ��������� �������� OUTPUT, �� ������ TRUE � ������ ������ ��������
begin
  Result := LoadLptReg(0);
end;

function LptChangeInput: Boolean;  // ���������� �������� �������� ��������� �������� INPUT, �� ������ TRUE � ������ ������ ��������
begin
  Result := LoadLptReg(1);
end;

function LptChangeInOut: Boolean;  // ���������� �������� �������� ��������� �������� IN/OUT, �� ������ TRUE � ������ ������ ��������
begin
  Result := LoadLptReg(2);
end;

function LptOutput: Byte; // �������� �������� OUTPUT
begin
  Result := LPTREGVALUE[0];
end;

function LptInput: Byte;  // �������� �������� INPUT
begin
  Result := LPTREGVALUE[1];
end;

function LptInOut: Byte;  // �������� �������� IN/OUT
begin
  Result := LPTREGVALUE[2];
end;

procedure SetValueToRegLpt(NomReg, RegValue: Byte);
begin
  LPTREGVALUE[NomReg] := Out32(ADDRREGLPT[NomReg], RegValue);
end;

procedure LptSetOutput(newValue: Byte); // ��������� ������ �������� �������� OUTPUT
begin
  SetValueToRegLpt(0, newValue);
end;

procedure LptSetInOut(newValue: Byte);  // ��������� ������ �������� �������� IN/OUT
begin
  SetValueToRegLpt(2, newValue);
end;

function GetBit(Value: Byte; BitNum: Byte): Boolean;
begin
  Result := ((Value shr BitNum) and 1) = 1
end;

function LptGetPin(PinNumb: Byte): Boolean;        // ���� �� ���������� �� ����� PinNumb
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

procedure LptSetPin(PinNumb: Byte; Volt: Boolean); // �������������/������� ���������� �� ����� PinNumb
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
for i := 0 to 2 do LoadLptReg(i); // �������� ������� �������� ��������� LPT �����

finalization
    
end.
