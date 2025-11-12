{ Naive minimax / alpha beta pruning with
  depth 4 so extremely slow on weak machines
  TODO: More winning conditions and reduce depth to 3 }

program Gomoku;

const
  SIZE = 15;
  EMP = '+';
  PL1 = 'O';
  PL2 = 'X';

type
  TBoard = array[1..SIZE,1..SIZE] of Char;

var
  Brd: TBoard;
  CX, CY: Byte;

function Min(X, Y: Integer): Integer;
begin
  if X < Y then
    Min := X
  else
    Min := Y;
end;

function Max(X, Y: Integer): Integer;
begin
  if X > Y then
    Max := X
  else
    Max := Y;
end;

procedure MoveTo(X, Y: Byte);
begin
  CX := X;
  CY := Y;
  GotoXY(X * 2 - 1, Y);
end;

procedure InitBrd;
var
  I, J: Byte;
begin
  ClrScr;
  TextColor(15);
  FillChar(Brd, SIZE*SIZE, EMP);
  for J:= 1 to SIZE do
  begin
    for I := 1 to SIZE do
      Write(Brd[I,J], ' ');
    Writeln;
  end;
  MoveTo(SIZE div 2, SIZE div 2);
end;

function Plot(X, Y: Byte; C: Char; Col: Byte): Boolean;
begin
  if Brd[X,Y] <> EMP then
    Plot := False
  else
    Plot := True;
  MoveTo(X, Y);
  Brd[X,Y] := C;
  TextColor(Col);
  Write(C);
  TextColor(7);
  MoveTo(X, Y);
end;

function Sample(X, Y: Byte): Char;
begin
  if (X >= 1) and (X <= SIZE) and (Y >= 1) and (Y <= Size) then
    Sample := Brd[X,Y]
  else
    Sample := EMP;
end;

function CheckDir(X, Y: Byte; DX, DY: Integer; C: Char): Integer;
var
  Check: Char;
  Count: Integer;
begin
  if (X = 0) or (Y = 0) then
  begin
    CheckDir := 0;
    exit;
  end;
  Count := 0;
  Check := Brd[X,Y];
  while Check = C do
  begin
    Count := Count + 1;
    X := X + DX;
    Y := Y + DY;
    if (X > SIZE) or (X < 1) or (Y > SIZE) or (Y < 1) then
    begin
      CheckDir := Count;
      exit;
    end;
    Check := Brd[X,Y];
  end;
  CheckDir := Count;
end;

function CheckWin(X, Y: Byte; DX, DY: Integer; C: Char): Boolean;
var
  Count: Integer;
begin
  Count := CheckDir(X, Y, DX, DY, C);
  Count := CheckDir(X, Y, -DX, -DY, C) + Count - 1;
  CheckWin := Count >= 5;
end;

function IsWinningMove(X, Y: Byte; C: Char): Boolean;
begin
  IsWinningMove :=
    CheckWin(X, Y, 1, 0, C) or
    CheckWin(X, Y, 0, 1, C) or
    CheckWin(X, Y, 1, 1, C) or
    CheckWin(X, Y, 1, -1, C);
end;

function HasNeighbor(X, Y: Byte): Boolean;
begin
  HasNeighbor :=
    (Sample(X - 1, Y) <> EMP) or
    (Sample(X + 1, Y) <> EMP) or
    (Sample(X, Y - 1) <> EMP) or
    (Sample(X, Y + 1) <> EMP) or
    (Sample(X - 1, Y - 1) <> EMP) or
    (Sample(X + 1, Y - 1) <> EMP) or
    (Sample(X + 1, Y + 1) <> EMP) or
    (Sample(X - 1, Y + 1) <> EMP);
end;

procedure ClearLine(Y: Byte);
var
  I: Byte;
begin
  GotoXY(1, Y);
  for I := 1 to 78 do
    Write(' ');
end;

procedure PrintEval(E: Integer);
begin
  ClearLine(22);
  GotoXY(1, 22);
  Write('Eval: ', E);
end;

procedure PrintBestMove(X, Y: Byte);
begin
  ClearLine(23);
  GotoXY(1, 23);
  Write('Best: ', X, ' ', Y);
end;

function EvaluateSingle(X, Y: Byte; C: Char): Integer;
var
  Score: Integer;
  I, J: Byte;
begin
  Score := 0;
  if IsWinningMove(X, Y, C) then
  begin
    Score := 10000;
  end else
  begin
    for J := 1 to SIZE do
    begin
      for I := 1 to SIZE do
      begin
        if Brd[I,J] = C then
        begin
          Score := Score + 1;
          if Sample(I - 1, J) = C then
            Score := Score + 1;
          if Sample(I + 1, J) = C then
            Score := Score + 1;
          if Sample(I, J - 1) = C then
            Score := Score + 1;
          if Sample(I, J + 1) = C then
            Score := Score + 1;
          if Sample(I - 1, J - 1) = C then
            Score := Score + 1;
          if Sample(I + 1, J - 1) = C then
            Score := Score + 1;
          if Sample(I + 1, J + 1) = C then
            Score := Score + 1;
          if Sample(I - 1, J + 1) = C then
            Score := Score + 1;
        end;
      end;
    end;
  end;
  EvaluateSingle := Score;
end;

function Evaluate(X, Y: Byte): Integer;
begin
  Evaluate :=
    EvaluateSingle(X, Y, PL2) - EvaluateSingle(X, Y, PL1);
end;

function Minimax(
  Depth: Byte; Alpha, Beta: Integer; X, Y: Byte; C: Char;
  var BX, BY: Byte): Integer;
var
  OC, Old: Char;
  B: Boolean;
  T, I, J: Byte;
  Eval, MaxEval, MinEval: Integer;
begin
  if Depth = 0 then
  begin
    Minimax := Evaluate(X, Y);
    exit;
  end;
  if C = PL1 then
    OC := PL2
  else
    OC := PL1;
  if C = PL2 then
  begin
    if IsWinningMove(X, Y, OC) then
    begin
      Minimax := -10000;
      exit;
    end;
    MaxEval := -32000;
    for J := 1 to SIZE do
    begin
      for I := 1 to SIZE do
      begin
        Old := Brd[I,J];
        if (Old = EMP) and HasNeighbor(I, J) then
        begin
          Brd[I,J] := C;
          Eval := Minimax(Depth - 1, Alpha, Beta, I, J, OC, T, T);
          Brd[I,J] := Old;
          if Eval > MaxEval then
          begin
            MaxEval := Eval;
            BX := I; BY := J;
          end;
          Alpha := Max(Alpha, Eval);
          if Beta <= Alpha then
          begin
            Minimax := MaxEval;
            exit;
          end;
        end;
      end;
    end;
    Minimax := MaxEval;
  end else
  begin
    if IsWinningMove(X, Y, OC) then
    begin
      Minimax := 10000;
      exit;
    end;
    MinEval := 32000;
    for J := 1 to SIZE do
    begin
      for I := 1 to SIZE do
      begin
        Old := Brd[I,J];
        if (Old = EMP) and HasNeighbor(I, J) then
        begin
          Brd[I,J] := C;
          Eval := Minimax(Depth - 1, Alpha, Beta, I, J, OC, T, T);
          Brd[I,J] := Old;
          if Eval < MinEval then
          begin
            MinEval := Eval;
            BX := I; BY := J;
          end;
          Beta := Min(Beta, Eval);
          if Beta <= Alpha then
          begin
            Minimax := MinEval;
            exit;
          end;
        end;
      end;
    end;
    Minimax := MinEval;
  end;
end;

procedure GameLoop;
var
  C: Char;
  B: Boolean;
  BX, BY: Byte;
  Eval: Integer;
  IsWin: Byte;
begin
  C := #0;
  IsWin := 0;
  repeat
    Read(Kbd, C);
    case C of
      #32: { Space }
        begin
          B := Plot(CX, CY, PL1, 10);
          if IsWinningMove(CX, CY, PL1) then
          begin
            IsWin := 1;
          end else
          begin
            BX := 0; BY := 0;
            Eval := Minimax(4, -32000, 32000, 0, 0, PL2, BX, BY);
            PrintEval(Eval);
            PrintBestMove(BX, BY);
            B := Plot(BX, BY, PL2, 14);
            if IsWinningMove(BX, BY, PL2) then
              IsWin := 2;
          end;
        end;
      'n':
        begin
          InitBrd;
        end;
      'i': { Up }
        begin
          if CY > 1 then
            MoveTo(CX, CY - 1);
        end;
      'k': { Down }
        begin
          if CY < SIZE then
            MoveTo(CX, CY + 1);
        end;
      'j': { Left }
        begin
          if CX > 1 then
            MoveTo(CX - 1, CY);
        end;
      'l': { Right}
        begin
          if CX < SIZE then
            MoveTo(CX + 1, CY);
        end;

    end;
    if IsWin <> 0 then
    begin
      GotoXY(33, 11);
      TextColor(13);
      Writeln('Player ', IsWin, ' wins!');
      Readln;
      InitBrd;
      IsWin := 0;
    end;
  until C = #27;
end;

begin
  InitBrd;
  GameLoop;
  ClrScr;
end.