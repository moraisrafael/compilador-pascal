program teste1 (input, output);
label 100;
var m,n :  integer;
	a,b : integer;
begin
	a := 2 - 3;
	b := 3 * 2;
	m := 4 div 2;
	goto 100;
	n := 4 + 4;
	100: a := b + m;
	read(a);
	b := 0;
	while (b < a) do
		begin
			if (b = 1) then
				write(42)
			else
				write(b);
			b := b + 1
		end
end.

