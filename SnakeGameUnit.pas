unit SnakeGameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, System.Messaging,
  SnakeLogicUnit;

type
  TSnakeForm = class(TForm)
    LayoutMain: TLayout;
    PaintBox: TPaintBox;
    LayoutInfo: TLayout;
    LabelScore: TLabel;
    LabelHighScore: TLabel;
    LabelGameStatus: TLabel;
    ButtonStart: TButton;
    ButtonPause: TButton;
    ButtonReset: TButton;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
    procedure TimerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonPauseClick(Sender: TObject);
    procedure ButtonResetClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    SnakeGame: TSnakeGame;
    GameRunning: Boolean;
    GamePaused: Boolean;
    CellSize: Integer;
    procedure UpdateUI;
    procedure DrawGame(Canvas: TCanvas);
    procedure DrawSnake(Canvas: TCanvas);
    procedure DrawFood(Canvas: TCanvas);
    procedure DrawGrid(Canvas: TCanvas);
  public
  end;

var
  SnakeForm: TSnakeForm;

implementation

{$R *.fmx}

procedure TSnakeForm.FormCreate(Sender: TObject);
begin
  SnakeGame := TSnakeGame.Create;
  GameRunning := False;
  GamePaused := False;
  CellSize := 20;
  
  // Set form properties
  Caption := 'Snake Game - Delphi 13.1';
  Width := (GRID_WIDTH * CellSize) + 50;
  Height := (GRID_HEIGHT * CellSize) + 250;
  
  // Set layout properties
  LayoutMain.Align := TAlignLayout.Client;
  PaintBox.Align := TAlignLayout.Top;
  PaintBox.Height := GRID_HEIGHT * CellSize + 20;
  LayoutInfo.Align := TAlignLayout.Client;
  
  // Initialize UI
  UpdateUI;
end;

procedure TSnakeForm.FormDestroy(Sender: TObject);
begin
  if Assigned(SnakeGame) then
    SnakeGame.Free;
end;

procedure TSnakeForm.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if not GameRunning or GamePaused then
    Exit;

  case Key of
    vkUp, Ord('W'):
      SnakeGame.ChangeDirection(dirUp);
    vkDown, Ord('S'):
      SnakeGame.ChangeDirection(dirDown);
    vkLeft, Ord('A'):
      SnakeGame.ChangeDirection(dirLeft);
    vkRight, Ord('D'):
      SnakeGame.ChangeDirection(dirRight);
    vkEscape:
      ButtonPauseClick(nil);
  end;
end;

procedure TSnakeForm.ButtonStartClick(Sender: TObject);
begin
  if not GameRunning then
  begin
    if not GamePaused then
    begin
      SnakeGame.ResetGame;
    end;
    GameRunning := True;
    GamePaused := False;
    Timer.Enabled := True;
    ButtonStart.Enabled := False;
    ButtonPause.Enabled := True;
    LabelGameStatus.Text := 'Game Running';
    LabelGameStatus.TextSettings.FontColor := TAlphaColorRec.Green;
  end;
end;

procedure TSnakeForm.ButtonPauseClick(Sender: TObject);
begin
  if GameRunning then
  begin
    GamePaused := not GamePaused;
    Timer.Enabled := not GamePaused;
    
    if GamePaused then
    begin
      LabelGameStatus.Text := 'Game Paused';
      LabelGameStatus.TextSettings.FontColor := TAlphaColorRec.Orange;
      ButtonPause.Text := 'Resume';
    end
    else
    begin
      LabelGameStatus.Text := 'Game Running';
      LabelGameStatus.TextSettings.FontColor := TAlphaColorRec.Green;
      ButtonPause.Text := 'Pause';
    end;
  end;
end;

procedure TSnakeForm.ButtonResetClick(Sender: TObject);
begin
  GameRunning := False;
  GamePaused := False;
  Timer.Enabled := False;
  SnakeGame.ResetGame;
  ButtonStart.Enabled := True;
  ButtonPause.Enabled := False;
  ButtonPause.Text := 'Pause';
  LabelGameStatus.Text := 'Game Reset';
  LabelGameStatus.TextSettings.FontColor := TAlphaColorRec.Navy;
  UpdateUI;
  PaintBox.InvalidateRect(PaintBox.BoundsF);
end;

procedure TSnakeForm.TimerTimer(Sender: TObject);
begin
  if GameRunning and not GamePaused then
  begin
    if not SnakeGame.Update then
    begin
      // Game Over
      GameRunning := False;
      Timer.Enabled := False;
      ButtonStart.Enabled := True;
      ButtonPause.Enabled := False;
      LabelGameStatus.Text := 'Game Over!';
      LabelGameStatus.TextSettings.FontColor := TAlphaColorRec.Red;
      ShowMessage('Game Over!' + sLineBreak + 'Score: ' + IntToStr(SnakeGame.Score) +
        sLineBreak + 'High Score: ' + IntToStr(SnakeGame.HighScore));
    end;
    UpdateUI;
    PaintBox.InvalidateRect(PaintBox.BoundsF);
  end;
end;

procedure TSnakeForm.UpdateUI;
begin
  LabelScore.Text := 'Score: ' + IntToStr(SnakeGame.Score);
  LabelHighScore.Text := 'High Score: ' + IntToStr(SnakeGame.HighScore);
end;

procedure TSnakeForm.PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
begin
  Canvas.Fill.Color := TAlphaColorRec.White;
  Canvas.FillRect(Canvas.ClipRect, 0, 0, [], 1);
  
  DrawGrid(Canvas);
  DrawGame(Canvas);
end;

procedure TSnakeForm.DrawGrid(Canvas: TCanvas);
var
  I: Integer;
  X, Y: Single;
begin
  Canvas.Stroke.Color := TAlphaColorRec.Lightgray;
  Canvas.Stroke.Thickness := 0.5;

  // Draw vertical lines
  for I := 0 to GRID_WIDTH do
  begin
    X := I * CellSize + 10;
    Canvas.DrawLine(PointF(X, 10), PointF(X, 10 + GRID_HEIGHT * CellSize), 1);
  end;

  // Draw horizontal lines
  for I := 0 to GRID_HEIGHT do
  begin
    Y := I * CellSize + 10;
    Canvas.DrawLine(PointF(10, Y), PointF(10 + GRID_WIDTH * CellSize, Y), 1);
  end;
end;

procedure TSnakeForm.DrawGame(Canvas: TCanvas);
begin
  DrawSnake(Canvas);
  DrawFood(Canvas);
end;

procedure TSnakeForm.DrawSnake(Canvas: TCanvas);
var
  I: Integer;
  Segment: TPoint;
  X, Y: Single;
begin
  for I := 0 to SnakeGame.SnakeLength - 1 do
  begin
    Segment := SnakeGame.SnakeBody[I];
    X := 10 + Segment.X * CellSize;
    Y := 10 + Segment.Y * CellSize;

    if I = 0 then
      // Head - Green
      Canvas.Fill.Color := TAlphaColorRec.Green
    else
      // Body - Lightgreen
      Canvas.Fill.Color := TAlphaColorRec.Lightgreen;

    Canvas.FillRect(RectF(X + 1, Y + 1, X + CellSize - 1, Y + CellSize - 1), 0, 0, [], 1);
    
    // Draw border
    Canvas.Stroke.Color := TAlphaColorRec.Darkgreen;
    Canvas.Stroke.Thickness := 1;
    Canvas.DrawRect(RectF(X + 1, Y + 1, X + CellSize - 1, Y + CellSize - 1), 0, 0, [], 1);
  end;
end;

procedure TSnakeForm.DrawFood(Canvas: TCanvas);
var
  X, Y: Single;
begin
  X := 10 + SnakeGame.FoodX * CellSize;
  Y := 10 + SnakeGame.FoodY * CellSize;

  // Draw food as red circle
  Canvas.Fill.Color := TAlphaColorRec.Red;
  Canvas.FillEllipse(RectF(X + 3, Y + 3, X + CellSize - 3, Y + CellSize - 3), 1);

  // Draw border
  Canvas.Stroke.Color := TAlphaColorRec.Darkred;
  Canvas.Stroke.Thickness := 1;
  Canvas.DrawEllipse(RectF(X + 3, Y + 3, X + CellSize - 3, Y + CellSize - 3), 1);
end;

end.