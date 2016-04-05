unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, StdCtrls, LPTinpout32, jpeg, MMSystem, Spin;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Image1: TImage;
    PaintBox1: TPaintBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Timer2: TTimer;
    SpinEdit1: TSpinEdit;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer2Timer(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    procedure RedrawPINS;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  TimerID : UINT; //идентификатор таймера

implementation

type
  TPin = record
    Rect: TRect;
    Text: string;
    Voltage: Boolean;
  end;

var
  ShemaLPT: TBitmap;
  Pins: array [1..25] of TPin;

function ByteToBin(Value: Byte): string;
var 
   Res: string;
begin
  Res := '';
 
  while Value <> 0 do 
    begin
      Res := Char(48 + (Value and 1)) + Res;
      Value := Value shr 1;
     end;

  while Length(Res) < 8 do Res := '0' + Res;

  Result := Res;
end; 


{$R *.dfm}

procedure TForm1.RedrawPINS;
var
  i: Integer;
begin
  for i := 1 to 17 do Pins[i].Voltage := LptGetPin(i);
  //LabelOutput.Caption := ByteToBin(LptOutput) + ' (' + IntToStr(LptOutput)+ ')';
  //LabelInput.Caption := ByteToBin(LptInput) + ' (' + IntToStr(LptInput)+ ')';
  //LabelInOut.Caption := ByteToBin(LptInOut) + ' (' + IntToStr(LptInOut)+ ')';
  PaintBox1.Invalidate;
end;

function GetPinRect(Nom: Byte): TRect;
begin
  Result.Left := 615 - Nom*40 + 1; 
  Result.Top := 155 + 1;
  
  if Nom > 13 then 
    begin
      Result.Left := Result.Left + 500;
      Result.Top := Result.Top + 40;
    end;
    
  Result.Right := Result.Left + 30 - 1;
  Result.Bottom := Result.Top + 30 - 1;
end;

function timeGetMinPeriod(): DWORD;
var  time: TTimeCaps;
begin
  timeGetDevCaps(Addr(time), SizeOf(time));
  timeGetMinPeriod := time.wPeriodMin;
end;

{function timeGetMaxPeriod(): Cardinal;
var time: TTimeCaps;
begin
  timeGetDevCaps(Addr(time), SizeOf(time));
  timeGetMaxPeriod := time.wPeriodMax;
end;

function timeSetTimerPeriod(period: Cardinal): Boolean;
begin
  if timeBeginPeriod(period) = TIMERR_NOERROR then
    begin
      //Сохраним значение для восстановления состояния таймера
      lastPeriod := period;
      timeSetTimerPeriod := True;
    end
  else//Неудача
    timeSetTimerPeriod := False;
end;}

procedure TimerProc(uTimerID, uMessage: UINT; dwUser, dw1, dw2: DWORD) stdcall;
begin
 if LptChangeInput or LptChangeInOut or LptChangeOutput then Form1.RedrawPINS;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  DoubleBuffered := True;

  ShemaLPT := TBitmap.Create;
  ShemaLPT.Width := Image1.Width;
  ShemaLPT.Height := Image1.Height;
  ShemaLPT.Canvas.Draw(0,0, Image1.Picture.Graphic);

  for i := 1 to 25 do
    begin
      Pins[i].Rect := GetPinRect(i);
      Pins[i].Text := IntToStr(i);
      Pins[i].Voltage := False;
    end;

  RedrawPINS;

  TimerID:=timeSetEvent(5, timeGetMinPeriod, TimerProc, 0, TIME_CALLBACK_FUNCTION or TIME_PERIODIC);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if LptChangeInput or LptChangeInOut or LptChangeOutput then RedrawPINS;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  ShemaLPT.Free;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  i: Integer;
begin
  with PaintBox1.Canvas do
    begin
      Draw(0,0, ShemaLPT);
      Brush.Style := bsClear;
      Font.Name := 'Arial';
      for i := 1 to 25 do
        begin
          if i < 18 then Font.Color := clBlack else Font.Color := clWhite;
          if i in [1,11,14,17] then Font.Color := clYellow;
          if Pins[i].Voltage then begin
           Font.Size := 14;
           Font.Style:=[fsBold];
          end else Font.Size := 6;
          DrawText(Handle, PChar(Pins[i].Text), -1, Pins[i].Rect, DT_SINGLELINE OR DT_VCENTER OR DT_CENTER);
        end;        
    end;
end;

function PointInRect(X,Y: Integer; R: TRect): Boolean;
begin
  Result := (X >= R.Left) and (X <= R.Right) and (Y >= R.Top) and (Y <= R.Bottom);
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i, nom: Integer;  
begin
  nom := 0;
  for i := 1 to 17 do
    if PointInRect(X,Y, Pins[i].Rect) then
      begin
        nom := i;
        Break;
      end;
  if not (nom in [10..13, 15]) then
    begin
      LptSetPin(nom, not Pins[nom].Voltage);
      RedrawPINS;
    end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 timeKillEvent(TimerID);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
 Application.ProcessMessages;
 Sleep(Random(500));
 LptSetPin(8,True);
 Sleep(50);
 LptSetPin(8,False);
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
 Timer2.Enabled:=False;
 Timer2.Interval:=SpinEdit1.Value;
 Timer2.Enabled:=True;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
 i,j:integer;
begin
 Button1.Enabled:=False;
 for i:=0 to 100 do begin
  j:=random(7);
  LptSetPin(j,True);
  sleep(1);
  LptSetPin(j,False);
  Application.ProcessMessages;
 end; //for
 Button1.Enabled:=True;
end;

initialization
 Randomize;

end.
