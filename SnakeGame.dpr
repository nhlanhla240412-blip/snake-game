program SnakeGame;

uses
  System.StartUpCopy,
  FMX.Forms,
  SnakeGameUnit in 'SnakeGameUnit.pas' {SnakeForm},
  SnakeLogicUnit in 'SnakeLogicUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TSnakeForm, SnakeForm);
  Application.Run;
end.