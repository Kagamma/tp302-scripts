{ Generate maze using recursive backtrack algorithm }

program Maze1;

const
  WIDTH  = 78; { Include borders }
  HEIGHT = 22;

var
  Maze: array[0..WIDTH, 0..HEIGHT] of Char;
  DX: array[0..3] of Integer;
  DY: array[0..3] of Integer;

procedure InitMaze;
var
  I, J: Byte;
begin
  for I := 0 to WIDTH do
    for J := 0 to HEIGHT do
      Maze[I,J] := '#';
end;

procedure PrintMaze;
var
  I, J: Integer;
  S: String[80];
begin
  ClrScr;
  for J := 0 to HEIGHT do
  begin
    S := '';
    for I := 0 to WIDTH do
      S := S + Maze[I,J];
    Writeln(S);
  end;
end;

procedure Carve(X, Y: Integer);
var
  I, NX, NY, PX, PY, Dir: Integer;
  Neighbors: array[0..3] of Boolean;
begin
  Maze[X,Y] := ' ';
  GotoXY(X + 1, Y + 1);
  Write(' ');
  for I := 0 to 3 do
    Neighbors[I] := True;
  for I := 0 to 3 do
  begin
    Dir := Random(4);
    while not Neighbors[Dir] do
      Dir := Random(4);
    Neighbors[Dir] := False;

    NX := X + DX[Dir] * 2;
    NY := Y + DY[Dir] * 2;

    if (NX >= 1)
      and (NX <= WIDTH - 1)
      and (NY >= 1)
      and (NY <= HEIGHT - 1)
      and (Maze[NX,NY] = '#') then
    begin
      PX := X + DX[Dir];
      PY := Y + DY[Dir];
      Maze[PX,PY] := ' ';
      Delay(100);
      GotoXY(PX + 1, PY + 1);
      Write(' ');
      Carve(NX, NY);
    end;
  end;
end;

begin
  DX[0] := 0;  DX[1] := 1; DX[2] := 0; DX[3] := -1;
  DY[0] := -1; DY[1] := 0; DY[2] := 1; DY[3] := 0;
  Randomize;
  InitMaze;
  PrintMaze;
  Carve(1, 1);
end.