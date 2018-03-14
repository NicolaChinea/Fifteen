unit uHighScores;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.IniFiles,
{$IF DEFINED(POSIX)}
  Posix.stdlib,
  posix.unistd,
{$ENDIF}

  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox,
  FMX.Objects, FMX.ListView.Types, FMX.ListView,
  FMX.Controls.Presentation, FMX.Edit, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base;

type
  THighScoresFrame = class(TFrame)
    Rectangle1: TRectangle;
    ListView1: TListView;
    Label1: TLabel;
    InputBGRect: TRectangle;
    InputBoxRect: TRectangle;
    Label2: TLabel;
    InputEdit: TEdit;
    GridPanelLayout1: TGridPanelLayout;
    OkayBTN: TButton;
    CancelBTN: TButton;
    Line1: TLine;
    Rectangle10: TRectangle;
    ContinueBTN: TRectangle;
    OKText: TText;
    sbDelete: TSpeedButton;
    procedure OkayBTNClick(Sender: TObject);
    procedure CancelBTNClick(Sender: TObject);
    procedure sbDeleteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    fGameType: String;
    fsTime: String;
    procedure AddScore(Name: String;  oTime:String; Score: Integer);
    procedure SaveScore(Name: String; oTime:String; Score: Integer);
    procedure InitFrame;
    procedure CloseInputBox;
    procedure PopulateHighScores;
  end;

implementation

uses
  IOUtils, FMX.DialogService.Async, f.Main;

{$R *.fmx}

procedure THighScoresFrame.CancelBTNClick(Sender: TObject);
begin
  CloseInputBox;
end;

procedure THighScoresFrame.AddScore(Name: String; oTime:String; Score: Integer);
begin
  if Name.Trim <> '' then
  begin
    SaveScore(Name, oTime, Score);
  end
  else
  begin
    fsTime := oTime;
    InputEdit.Tag := Score;
    InputBGRect.Visible := True;
    InputBGRect.BringToFront;
    InputBoxRect.Visible := True;
    InputBoxRect.BringToFront;
  end;
end;

procedure THighScoresFrame.SaveScore(Name: String; oTime:String; Score: Integer);
var
IniFile: TMemIniFile;
begin
  if (Name.Trim <> '') then
  begin
    IniFile := TMemIniFile.Create(FMain.SettingsFilePath + 'Punteggio'+fGameType+'.ini');
    try
      IniFile.WriteInteger('Punteggio', Name + ' [' + oTime + ']', Score );
      IniFile.UpdateFile;
    finally
      IniFile.Free;
    end;
    PopulateHighScores;
  end;
end;

procedure THighScoresFrame.sbDeleteClick(Sender: TObject);
begin
  TDialogServiceAsync.MessageDialog('Cancellare i punteggi?',
    System.UITypes.TMsgDlgType.mtInformation,
    [System.UITypes.TMsgDlgBtn.mbYes,
    System.UITypes.TMsgDlgBtn.mbNo], System.UITypes.TMsgDlgBtn.mbYes, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrYes:
          begin
            TThread.Synchronize(nil,
                                procedure
                                begin
                                  DeleteFile(FMain.SettingsFilePath + 'Punteggio' + fGameType + '.ini');
                                  ListView1.Items.Clear;
                                end);
          end;
        mrNo:
          begin
//
          end;
      end;
    end);

end;

Function StringListSortCompareV(List: TStringList; Index1,Index2: Integer): Integer;
var A, B: Integer;
begin
  A := StrToIntDef(List.ValueFromIndex[Index1], -1);
  B := StrToIntDef(List.ValueFromIndex[Index2], -1);
  Result := A - B;
end;

procedure THighScoresFrame.PopulateHighScores;
var
I: Integer;
SL: TStringList;
IniFile: TMemIniFile;
LItem: TListViewItem;
begin
  SL := TStringList.Create;
  IniFile := TMemIniFile.Create(FMain.SettingsFilePath + 'Punteggio' + fGameType + '.ini');
  try
    if IniFile.SectionExists('Punteggio')=True then
    begin
      ListView1.Items.Clear;
      IniFile.ReadSectionValues('Punteggio', SL);
      SL.CustomSort(StringListSortCompareV);
      for I := 0 to SL.Count-1 do
       begin
         LItem := ListView1.Items.Add();
         LItem.Text := SL.Names[I];
         LItem.Detail := SL.ValueFromIndex[I];
       end;
    end
    else
      ListView1.Items.Clear;
  finally
    FreeAndNil(IniFile);
    FreeAndNil(SL);
  end;
end;

procedure THighScoresFrame.InitFrame;
begin
  Label1.text := 'Punteggio (' + fGameType +')';
  InputEdit.text := '';
  try
    PopulateHighScores;
  except
    on e: Exception do
    begin
      ShowMessage(e.Message);
    end;
  end;
end;

procedure THighScoresFrame.CloseInputBox;
begin
  InputBGRect.Visible := False;
  InputBoxRect.Visible := False;
end;

Procedure THighScoresFrame.OkayBTNClick(Sender: TObject);
begin
  CloseInputBox;
  SaveScore(InputEdit.Text, fsTime, InputEdit.Tag);
end;

end.
