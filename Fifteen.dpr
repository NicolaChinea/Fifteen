program Fifteen;

uses
  System.StartUpCopy,
  FMX.Forms,
  f.Main in 'f.Main.pas' {fMain},
  uHighScores in 'uHighScores.pas' {HighScoresFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
