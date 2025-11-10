program eval;

type
  Double = Real;
  TExprString = String[255];
  TExprTokenKind = (
    tkEOL,
    tkUnknown,
    tkNumber,
    tkAdd,
    tkSub,
    tkMul,
    tkDiv,
    tkBracketOpen,
    tkBracketClose
  );

function Eval(Expr: TExprString): Double;
var
  Len, Cur: Integer;
  Data: Double;
  Stack: array[0..31] of Double;
  StackPtr: Integer;

  function NextToken: TExprTokenKind;
  var
    C: Char;
    S: TExprString;
    Code: Integer;

    function Peek: Char;
    var
      CI: Integer;
    begin
      CI := Cur + 1;
      if CI > Len then
        Peek := #0
      else
        Peek := Expr[CI];
    end;

  begin
    C := Peek;
    S := '';
    while C = ' ' do
    begin
      Cur := Cur + 1;
      C := Peek;
    end;
    case C of
      '0'..'9':
        begin
          NextToken := tkNumber;
          repeat
            Cur := Cur + 1;
            S := S + C;
            C := Peek;
          until not (C in ['0'..'9']);
          Val(S, Data, Code);
          case UpCase(C) of
            'M':
              begin
                Cur := Cur + 1;
              end;
            'G':
              begin
                Cur := Cur + 1;
                Data := Data * 1024;
              end;
            'T':
              begin
                Cur := Cur + 1;
                Data := Data * 1024 * 1024;
              end;
          end;
        end;
      '+':
        begin
          Cur := Cur + 1;
          NextToken := tkAdd;
        end;
      '-':
        begin
          Cur := Cur + 1;
          NextToken := tkSub;
        end;
      '*':
        begin
          Cur := Cur + 1;
          NextToken := tkMul;
        end;
      '/':
        begin
          Cur := Cur + 1;
          NextToken := tkDiv;
        end;
      '(':
        begin
          Cur := Cur + 1;
          NextToken := tkBracketOpen;
        end;
      ')':
        begin
          Cur := Cur + 1;
          NextToken := tkBracketClose;
        end;
      #0:
        begin
          NextToken := tkEOL;
        end;
      else
        NextToken := tkUnknown;
    end;
  end;

  function PeekToken: TExprTokenKind;
  var
    OldCur: Integer;
  begin
    OldCur := Cur;
    PeekToken := NextToken;
    Cur := OldCur;
  end;

  procedure Calc(Op: TExprTokenKind);
  var
    V1, V2: Double;
  begin
    if StackPtr < 2 then
      Exit;
    V2 := Stack[StackPtr - 1];
    V1 := Stack[StackPtr - 2];
    case Op of
      tkAdd:
        begin
          Writeln('Add ', V1:0:0, ',', V2:0:0);
          V1 := V1 + V2;
        end;
      tkSub:
        begin
          Writeln('Sub ', V1:0:0, ',', V2:0:0);
          V1 := V1 - V2;
        end;
      tkMul:
        begin
          Writeln('Mul ', V1:0:0, ',', V2:0:0);
          V1 := V1 * V2;
        end;
      tkDiv:
        begin
          Writeln('Div ', V1:0:0, ',', V2:0:0);
          V1 := V1 / V2;
        end;
    end;
    Stack[StackPtr - 2] := V1;
    StackPtr := StackPtr - 1;
  end;

  procedure AddSub; forward;

  procedure Numbers;
  var
    Op: TExprTokenKind;
  begin
    while True do
    case PeekToken of
      tkNumber:
        begin
          Op := NextToken;
          Stack[StackPtr] := Data;
          StackPtr := StackPtr + 1;
          Writeln('Push ', Data:0:0);
        end;
      tkBracketOpen:
        begin
          Op := NextToken;
          AddSub;
          Op := NextToken; { Close }
        end;
      else
        Exit;
    end;
  end;

  procedure MulDiv;
  var
    Op: TExprTokenKind;
  begin
    Numbers;
    while True do
    case PeekToken of
      tkMul, tkDiv:
        begin
          Op := NextToken;
          Numbers;
          Calc(Op);
        end;
      else
        Exit;
    end;
  end;

  procedure AddSub;
  var
    Op: TExprTokenKind;
  begin
    MulDiv;
    while True do
    case PeekToken of
      tkAdd, tkSub:
        begin
          Op := NextToken;
          MulDiv;
          Calc(Op);
        end;
      else
       Exit;
    end;
  end;

begin
  Len := Length(Expr);
  Cur := 0;
  StackPtr := 0;
  AddSub;
  Eval := Stack[0];
end;

var
  Expr: TExprString;
  Res: Real;

begin
  Writeln('Evaluate expression for tparted.');
  Writeln('Default is MiB.');
  Writeln('Supported postfixes: G (GiB), T (TiB)');
  Write('Enter expression: ');
  Readln(Expr);
  Res := Eval(Expr);
  Writeln('Result: ', Res:0:4);
end.