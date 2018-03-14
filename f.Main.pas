unit f.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Ani, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox,
  System.Diagnostics,
  FMX.MultiView, FMX.Edit, uHighScores, System.IniFiles;

type sss= record
  coord: TPoint;
  oRect: TRectangle;
end;
type
  TfMain = class(TForm)
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    Rectangle4: TRectangle;
    Rectangle8: TRectangle;
    Rectangle7: TRectangle;
    Rectangle6: TRectangle;
    Rectangle5: TRectangle;
    Rectangle9: TRectangle;
    Rectangle10: TRectangle;
    Rectangle11: TRectangle;
    Rectangle12: TRectangle;
    Rectangle15: TRectangle;
    Rectangle14: TRectangle;
    Rectangle13: TRectangle;
    Rectangle16: TRectangle;
    rFondo: TRectangle;
    btShuffle: TButton;
    LayoutMain: TLayout;
    MainToolBar: TToolBar;
    ToolBarBGRectangle: TRectangle;
    HeaderText: TText;
    Rectangle17: TRectangle;
    MenuButton: TButton;
    MultiView: TMultiView;
    Circle2: TCircle;
    ListBox1: TListBox;
    ConfigLBI: TListBoxItem;
    ExitLBI: TListBoxItem;
    VSB: TVertScrollBox;
    StyleBook: TStyleBook;
    cbSequenze: TComboBox;
    LayoutType: TLayout;
    Layout2: TLayout;
    btPunteggi: TButton;
    HighScoresFrame: THighScoresFrame;
    LayoutTime: TLayout;
    lTime: TLabel;
    eTempo: TEdit;
    LayoutMove: TLayout;
    lMosse: TLabel;
    eMosse: TEdit;
    procedure TileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btShuffleClick(Sender: TObject);
    procedure ExitLBIClick(Sender: TObject);
    procedure ConfigLBIClick(Sender: TObject);
    procedure cbSequenzeChange(Sender: TObject);
    procedure btPunteggiClick(Sender: TObject);
    procedure HighScoresFrameContinueBTNClick(Sender: TObject);
    procedure HighScoresFrameOkayBTNClick(Sender: TObject);
    procedure HighScoresFrameCancelBTNClick(Sender: TObject);
  private
  // per ora statico ma in futuro dinamico
    aGrid: Array[1..4, 1..4] of TRectangle;
    fX_POS16: Byte;
    fY_POS16: Byte;
    flMove: Boolean; // x ora sempre attivo ... vediamo
    fXY_Point16: TPoint;  // non utilizzato
    fnTilepos: Byte;
    fSettingsFilePath: String;
    IniFile: TMemIniFile;
    fnMoveCount: Integer;
    fnTimeCount: String;
    foTimer: TStopwatch;
    procedure IdleEvent(Sender: TObject; var Done: Boolean);
    procedure Scambio(Source, Dest: TRectangle; nDir: Byte);
    Function SelectTile(oRect: TRectangle): TPoint;
    function Valid(Const oValidPoint: Tpoint): Byte;
    procedure Movetile(const oPointMove: Tpoint);
    Procedure CreateGrid(numTile: Byte);
    Procedure RepaintTile;
    Function CheckWin: Boolean;
    procedure CloseHighScores;
    function GetnMoveCount: Integer;
    procedure SetnMoveCount(const Value: Integer);
    function GetnTimeCount: String;
    procedure SetnTimeCount(const Value: String);
    procedure Shuffle;

    { Private declarations }
  public
  // preparo tutto x usi futuri non si sa mai
    Property nTilepos: Byte read fnTilepos write fnTilepos;
    Property oTimer: TStopwatch read foTimer write foTimer;
    property X_POS16: Byte read fX_POS16 write fX_POS16;
    property Y_POS16: Byte read fY_POS16 write fY_POS16;
    Property XY_Point16: TPoint read fXY_Point16 write fXY_Point16;
    property lMove: Boolean read flMove write flMove;
    property nMoveCount: Integer read GetnMoveCount write SetnMoveCount;
    property nTimeCount: String read GetnTimeCount write SetnTimeCount;
    property SettingsFilePath: String read fSettingsFilePath write fSettingsFilePath;

    { Public declarations }
  end;

var
  fMain: TfMain;
CONST
  CS_DIR_ERROR = 0;
  CS_DIR_X = 1;
  CS_DIR_Y = 2;
  CS_TILE_MOVE = 80;
  CS_TILE_MARGIN_X = 5;
  CS_TILE_MARGIN_Y = 5;
  aSequenze: array[0..10] of string = ('01020304050607080910111213141516',
                                        '16010203040506070809101112131415',
                                        '01050913020610140307111504081216',
                                        '16040812010509130206101403071115',
                                        '01121110021316090314150804050607',
                                        '16111009011215080213140703040506',
                                        '01080916020710150306111404051213',
                                        '16070815010609140205101303041112',
                                        '01020304080706050910111216151413',
                                        '16010203070605040809101115141312',
                                        '');
implementation

{$R *.fmx}

uses IOUtils;

Procedure TfMain.Scambio(Source, Dest: TRectangle; nDir: Byte);
Begin
  if lMove then
  begin
    if nDir = CS_DIR_Y then
    begin
      TAnimator.AnimateFloat(source, 'Position.X', Dest.Position.X, 0.5);
      TAnimator.AnimateFloat(Dest, 'Position.X', Source.Position.X, 0.5);
    end
    else
    begin
      TAnimator.AnimateFloat(source, 'Position.Y', Dest.Position.Y, 0.5);
      TAnimator.AnimateFloat(Dest, 'Position.Y', Source.Position.Y, 0.5);
    end;
  end;
end;

Procedure TfMain.Shuffle;
Var i: Integer;
    oPoint: Tpoint;
    nTile: Integer;
Begin
  lMove := false;
  oTimer.Stop;
  oTimer.Reset;
  Randomize;
  For I := 1 to 600 do
  Begin
    Repeat
      nTile := Random(15) + 1;
      oPoint.Y := 1;
      While nTile > 4 do
      Begin
        oPoint.Y := oPoint.Y + 1;
        nTile := nTile - 4;
      end;
      oPoint.X := nTile;
    Until Valid(oPoint) <> CS_DIR_ERROR;
    Movetile(oPoint);
  end;
  RepaintTile;
  nMoveCount := 0;
  oTimer.Start;
  lMove := True;
end;

procedure TfMain.btShuffleClick(Sender: TObject);
Begin
  cbSequenze.ItemIndex := -1;
  cbSequenze.ItemIndex := 10;
end;

Function TfMain.SelectTile(oRect: TRectangle): TPoint;
Var Loop: TRectangle;
    i: Integer;
begin
  i:= 0;
  for Loop in aGrid do
  begin
    if oRect = Loop then
    begin
       result.y := (i div 4) + 1;
       result.x := (i mod 4) + 1;
       break;
    end;
    inc(i);
  end;
end;


function TfMain.GetnMoveCount: Integer;
begin
  Result := fnMoveCount;
end;


function TfMain.GetnTimeCount: String;
begin
  Result := fnTimeCount;
end;

procedure TfMain.SetnMoveCount(const Value: Integer);
begin
  fnMoveCount := Value;
  eMosse.Text := fnMoveCount.ToString;
end;

procedure TfMain.SetnTimeCount(const Value: String);
begin
  fnTimeCount := Value;
  eTempo.Text := fnTimeCount;
end;

Procedure TfMain.Movetile(Const oPointMove: Tpoint);
Var nDir: Byte;
    nDummy: Integer;
    oSource: TRectangle;
    oDest: TRectangle;
Begin
  nDir := Valid(oPointMove);
  If nDir = CS_DIR_ERROR Then
    Exit;
  oSource := aGrid[Y_POS16, X_POS16];
  If nDir = CS_DIR_X Then
  Begin
    Repeat
      If oPointMove.Y > Y_POS16 Then
        nDummy := 1
      Else if oPointMove.Y < Y_POS16 then
        nDummy := -1;
      oDest := aGrid[Y_POS16 + nDummy, X_POS16];
      aGrid[Y_POS16, X_POS16] := oDest;
      Y_POS16 := Y_POS16 + nDummy;
      aGrid[Y_POS16, X_POS16] := oSource;
      Scambio(oSource, oDest, nDir);
    Until oPointMove.Y = Y_POS16;
  end
  Else
  If nDir = CS_DIR_Y Then
  Begin
    Repeat
      If oPointMove.X > X_POS16 Then
        nDummy := 1
      Else if oPointMove.X < X_POS16 then
        nDummy := -1;
      oDest := aGrid[Y_POS16, X_POS16 + nDummy];
      aGrid[Y_POS16, X_POS16] := oDest;
      X_POS16 := X_POS16 + nDummy;
      aGrid[Y_POS16, X_POS16] := oSource;
      Scambio(oSource, oDest, nDir);
    Until oPointMove.X = X_POS16;
  end;
end;

procedure TfMain.RepaintTile;
Var i: Integer;
    Dummy_X, Dummy_Y: Single;
    Loop: TRectangle;
Begin
  i := 0;
  Dummy_X := CS_TILE_MARGIN_X;
  Dummy_Y := CS_TILE_MARGIN_Y;
  for Loop in aGrid do
  begin
    Loop.Position.X := Dummy_X;
    Loop.Position.Y := Dummy_Y;
    if ((i mod 4) + 1) = 4 then
    begin
      i := 0;
      Dummy_X := CS_TILE_MARGIN_X;
      Dummy_Y := Dummy_Y + CS_TILE_MOVE;
    end
    else
    begin
      Dummy_X := Dummy_X + CS_TILE_MOVE;
      inc(i);
    end;
  end;
end;

Function TfMain.Valid(Const oValidPoint: Tpoint): byte;
{
0 = ERRORE
1 = MOVIMENTO X
2 = MOVIMENTO Y
}
Begin
  Result := CS_DIR_ERROR;
  If (oValidPoint.X = X_POS16) And (oValidPoint.Y = Y_POS16) Then
  Begin
    Result := CS_DIR_ERROR;
    Exit;
  end;
  If (oValidPoint.X = X_POS16)Then
    Result := CS_DIR_X
  else If (oValidPoint.Y = Y_POS16)Then
    Result := CS_DIR_Y;
end;

procedure TfMain.btPunteggiClick(Sender: TObject);
begin
  HighScoresFrame.Visible := True;
  HighScoresFrame.BringToFront;
  HighScoresFrame.fGameType := cbSequenze.Items[cbSequenze.ItemIndex];
  HighScoresFrame.InitFrame;
end;

procedure TfMain.cbSequenzeChange(Sender: TObject);
var Loop: TRectangle;
    x, y, i: Integer;
    sSequenza: string;
    xpos, ypos: Integer;
  Function GetRectengle(nRect: Integer): TRectangle;
  var nNumRect: integer;
  begin
    nNumRect := Copy(sSequenza, (nRect * 2) - 1, 2).ToInteger;
    Result := FindComponent('Rectangle' + nNumRect.ToString) as TRectangle;
  end;
begin
  if cbSequenze.ItemIndex >= 0 then
  begin

    oTimer.Stop;
    oTimer.Reset;
    sSequenza := aSequenze[cbSequenze.ItemIndex];
    if sSequenza = '' then
    begin
      Shuffle
    //  btShuffleClick(Nil);
    end
    else
    begin
      i := 1;
      For y := 1 to 4 do
      begin
        For x := 1 to 4 do
        begin
          aGrid[y, x] := GetRectengle(i);
          if aGrid[y, x] = Rectangle16 then
          begin
            fX_POS16 := x;
            fY_POS16 := y;
          end;
          inc(i);
        end;
      end;
    end;
    RepaintTile;
    nMoveCount := 0;
    oTimer.Start;
    lMove := True;
  end;
end;

procedure TfMain.ConfigLBIClick(Sender: TObject);
begin
  Showmessage('Forse in futuro');
end;

procedure TfMain.CreateGrid(numTile: Byte);
begin
// devo creare una griglia in base al numero di mattonelle .... forse in futuro
// per adesso sequenza classica
  cbSequenzeChange(nil);
end;

procedure TfMain.ExitLBIClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  application.OnIdle := IdleEvent;
  foTimer := TStopwatch.Create;
{$IF DEFINED(MSWINDOWS)}
  SettingsFilePath := ExtractFilePath(ParamStr(0));
{$ELSE}
  SettingsFilePath := System.IOUtils.TPath.GetDocumentsPath +
    System.SysUtils.PathDelim;
{$ENDIF}
  IniFile := TMemIniFile.Create(SettingsFilePath + 'HiScore.ini');
  nTilepos := 4; // 4x4 ma non gestito
  nMoveCount := 0;
  nTimeCount := '00:00:000';
  CreateGrid(nTilepos);
end;


procedure TfMain.HighScoresFrameCancelBTNClick(Sender: TObject);
begin
  HighScoresFrame.CancelBTNClick(Sender);
end;

procedure TfMain.HighScoresFrameContinueBTNClick(Sender: TObject);
begin
  CloseHighScores;
end;

procedure TfMain.HighScoresFrameOkayBTNClick(Sender: TObject);
begin
  HighScoresFrame.OkayBTNClick(Sender);
end;


Function TfMain.CheckWin: Boolean;
Var Loop: TRectangle;
    i: Integer;
begin
  i:= 1;
  Result := True;
  for Loop in aGrid do
  begin
    if Loop.Tag <> i then
    begin
       Result := False;
       break;
    end;
    inc(i);
  end;

end;

procedure TfMain.CloseHighScores;
begin
  HighScoresFrame.Visible := False;
end;

procedure TfMain.TileClick(Sender: TObject);
Var oPoint:TPoint;
Begin
  oPoint := SelectTile(TRectangle(Sender));
  If Valid(oPoint) <> 0 Then
  Begin
    Movetile(oPoint);
    XY_Point16 := oPoint;  //.... vediamo se portare a tpoint
    X_POS16 := oPoint.X;
    Y_POS16 := oPoint.Y;
    nMoveCount := nMoveCount + 1;
    if CheckWin then
    begin
      oTimer.Stop;
      oTimer.Reset;
      lMove := False;
      HighScoresFrame.fGameType := cbSequenze.Items[cbSequenze.ItemIndex];
      HighScoresFrame.InitFrame;
      HighScoresFrame.AddScore('', nTimeCount, nMoveCount);
      HighScoresFrame.Visible := True;
      HighScoresFrame.BringToFront;
      IniFile.WriteInteger('HiScore', 'HiScoreA', 10);
    end;

  end;
end;

procedure TfMain.IdleEvent(Sender: TObject; var Done: Boolean);
begin
  if oTimer.IsRunning then
    nTimeCount := Format('%.2d:%.2d', [oTimer.Elapsed.Minutes, oTimer.Elapsed.Seconds]);
end;

end.
