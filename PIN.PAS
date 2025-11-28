 { Terminator 2 - easy money hack }

program PIN;

var
 I, J, P, C: Byte;

begin
  ClrScr;
  TextMode(C40);
  {Window(1, 7, 40, 15);}
  Writeln('PPPPP  IIIIIII  N    N');
  Writeln('P   PP    I     NN   N IDENTIFICATION');
  Writeln('P   PP    I     N N  N');
  Writeln('PPPPP     I     N  N N   PROGRAM');
  Writeln('P         I     N   NN');
  Writeln('P      IIIIIII  N    N');
  Writeln;
  Writeln('Strike a key when ready ...');
  Readln;

  Writeln(#10#13#10#13'123456789012345678901234567890123456780');
  P:= 38;
  while P >= 5 do
  begin
    for J := 0 to 4 do
    begin
      for I := 0 to P - 1 do
        Write(Random(10));
      Writeln;
      Delay(20);
    end;
    if (C and 1) = 1 then
      P := P - 1
    else
      P := P - 2;
    C := C + 1;
  end;
  for I := 0 to 9 do
    Writeln('9003');
  Write(#10#13'PIN IDENTIFICATION NUMBER: 9003'#10#13#10#13'a>');
  Readln;
  TextMode(C80);
end.