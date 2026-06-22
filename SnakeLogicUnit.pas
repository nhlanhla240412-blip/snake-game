unit SnakeLogicUnit;

interface

uses
  System.Types, System.SysUtils, System.Math;

const
  GRID_WIDTH = 20;
  GRID_HEIGHT = 20;
  MAX_SNAKE_LENGTH = GRID_WIDTH * GRID_HEIGHT;

type
  TDirection = (dirUp, dirDown, dirLeft, dirRight);

  TSnakeGame = class
  private
    FSnakeBody: array[0..MAX_SNAKE_LENGTH - 1] of TPoint;
    FSnakeLength: Integer;
    FCurrentDirection: TDirection;
    FNextDirection: TDirection;
    FFoodX: Integer;
    FFoodY: Integer;
    FScore: Integer;
    FHighScore: Integer;
    procedure GenerateFood;
    function IsSnakeCollision(X, Y: Integer): Boolean;
    function IsValidMove(NewX, NewY: Integer): Boolean;
    procedure LoadHighScore;
    procedure SaveHighScore;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ResetGame;
    function Update: Boolean;
    procedure ChangeDirection(Direction: TDirection);
    property SnakeBody: array[0..MAX_SNAKE_LENGTH - 1] of TPoint read FSnakeBody;
    property SnakeLength: Integer read FSnakeLength;
    property FoodX: Integer read FFoodX;
    property FoodY: Integer read FFoodY;
    property Score: Integer read FScore;
    property HighScore: Integer read FHighScore;
  end;

implementation

uses
  System.IOUtils;

constructor TSnakeGame.Create;
begin
  inherited Create;
  LoadHighScore;
  ResetGame;
end;

destructor TSnakeGame.Destroy;
begin
  SaveHighScore;
  inherited Destroy;
end;

procedure TSnakeGame.LoadHighScore;
var
  HighScoreFile: string;
  HighScoreStr: string;
begin
  FHighScore := 0;
  try
    HighScoreFile := TPath.Combine(TPath.GetDocumentsPath, 'snake_highscore.txt');
    if TFile.Exists(HighScoreFile) then
    begin
      HighScoreStr := TFile.ReadAllText(HighScoreFile).Trim;
      if TryStrToInt(HighScoreStr, FHighScore) then
        FHighScore := FHighScore
      else
        FHighScore := 0;
    end;
  except
    FHighScore := 0;
  end;
end;

procedure TSnakeGame.SaveHighScore;
var
  HighScoreFile: string;
begin
  try
    HighScoreFile := TPath.Combine(TPath.GetDocumentsPath, 'snake_highscore.txt');
    TFile.WriteAllText(HighScoreFile, IntToStr(FHighScore));
  except
    // Silently fail if unable to save
  end;
end;

procedure TSnakeGame.ResetGame;
begin
  FSnakeLength := 3;
  FSnakeBody[0] := Point(GRID_WIDTH div 2, GRID_HEIGHT div 2);
  FSnakeBody[1] := Point(GRID_WIDTH div 2 - 1, GRID_HEIGHT div 2);
  FSnakeBody[2] := Point(GRID_WIDTH div 2 - 2, GRID_HEIGHT div 2);

  FCurrentDirection := dirRight;
  FNextDirection := dirRight;
  FScore := 0;

  GenerateFood;
end;

procedure TSnakeGame.GenerateFood;
var
  NewX, NewY: Integer;
begin
  repeat
    NewX := Random(GRID_WIDTH);
    NewY := Random(GRID_HEIGHT);
  until not IsSnakeCollision(NewX, NewY);

  FFoodX := NewX;
  FFoodY := NewY;
end;

function TSnakeGame.IsSnakeCollision(X, Y: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FSnakeLength - 1 do
  begin
    if (FSnakeBody[I].X = X) and (FSnakeBody[I].Y = Y) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TSnakeGame.IsValidMove(NewX, NewY: Integer): Boolean;
begin
  Result := (NewX >= 0) and (NewX < GRID_WIDTH) and
    (NewY >= 0) and (NewY < GRID_HEIGHT) and
    not IsSnakeCollision(NewX, NewY);
end;

procedure TSnakeGame.ChangeDirection(Direction: TDirection);
begin
  // Prevent reversing into itself
  if Direction = dirUp and FCurrentDirection <> dirDown then
    FNextDirection := dirUp
  else if Direction = dirDown and FCurrentDirection <> dirUp then
    FNextDirection := dirDown
  else if Direction = dirLeft and FCurrentDirection <> dirRight then
    FNextDirection := dirLeft
  else if Direction = dirRight and FCurrentDirection <> dirLeft then
    FNextDirection := dirRight;
end;

function TSnakeGame.Update: Boolean;
var
  NewX, NewY: Integer;
  I: Integer;
begin
  FCurrentDirection := FNextDirection;

  // Calculate new head position
  NewX := FSnakeBody[0].X;
  NewY := FSnakeBody[0].Y;

  case FCurrentDirection of
    dirUp:
      Dec(NewY);
    dirDown:
      Inc(NewY);
    dirLeft:
      Dec(NewX);
    dirRight:
      Inc(NewX);
  end;

  // Check if move is valid
  if not IsValidMove(NewX, NewY) then
  begin
    // Game Over - Update high score if needed
    if FScore > FHighScore then
    begin
      FHighScore := FScore;
      SaveHighScore;
    end;
    Result := False;
    Exit;
  end;

  // Move snake
  for I := FSnakeLength - 1 downto 1 do
    FSnakeBody[I] := FSnakeBody[I - 1];

  FSnakeBody[0] := Point(NewX, NewY);

  // Check if food is eaten
  if (NewX = FFoodX) and (NewY = FFoodY) then
  begin
    Inc(FScore, 10);
    if FSnakeLength < MAX_SNAKE_LENGTH then
    begin
      FSnakeBody[FSnakeLength] := FSnakeBody[FSnakeLength - 1];
      Inc(FSnakeLength);
    end;
    GenerateFood;
  end;

  Result := True;
end;

end.