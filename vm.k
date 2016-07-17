HALT: :[0]
G:{$[32768>x:b x;x;b x]}
S:{b[b x]:y}
RET:{if[32776=n:#b;:0];x:b n-:1;b _:n;x}
SET:{S[x]G x+1;x+2}
PUSH:{b,:G x;x+1}
POP:{S[x]RET x;x+1}
EQ:{S[x]0i+G[x+1]=G[x+2];x+3}
GT:{S[x]0i+G[x+1]>G[x+2];x+3}
JMP:G
JT:{$[G x;G x+1;x+2]}
JF:{$[G x;x+2;G x+1]}
MD:{"i"$x-y*_x%y}
MOD:{S[x]MD[G x+1;G x+2];x+3}
M15:MD[;32768]
ADD:{S[x]M15 G[x+1]+G x+2;x+3}
MULT:{S[x]M15 G[x+1]*G x+2;x+3}
AND:{S[x]@0b/:(0b\:G x+1)&0b\:G x+2;x+3}
OR:{S[x]@0b/:(0b\:G x+1)|0b\:G x+2;x+3}
NOT:{S[x]@0b/:(17#0b),~-15#0b\:G x+1;x+2}
RMEM:{S[x]G G x+1;x+2}
WMEM:{b[G x]:G x+1;x+2}
CALL:{b,:x+1;JMP x}
RL:{$[#l:r x;[r _:x;:0N!l];0: x]}
IN:{if[~b@-1+#b;while[|/"!#"=*r:RL 0;if["!"=*r;. 1_r]];b,:|"i"$r,"\n"];POP x}
OUT:{1"c"$G x;x+1}
NOOP:(::)
o:`HALT`SET`PUSH`POP`EQ`GT`JMP`JT`JF`ADD`MULT`MOD`AND`OR`NOT`RMEM`WMEM`CALL`RET`OUT`IN`NOOP
REG:@[;32768+!8]
STACK:32776_
x:1;r:0:`commands.txt;b:32776#|(32776#0i),(0x0/:0x0000,)'0N 2#|1:`challenge.bin
\
x:(~0=){o[G x]x+1}/x            / play til end
/ take step - display next index, register, stack and opcodes
x:0N!{o[G x]x+1} x;0N!REG b;0N!STACK b;0N!x _ b;

/ puzzle
/ _ + _ * _^2 + _^3 - _ = 399
f:{{x*x*x}[x 3]+(-x 4)+x[0]+x[1]*{x*x}[x 2]}
p:{x{,/(>:'t=/:t:*x)@\:x:0,'1+x}/,!0} / permutations
m:2 9 5 7 3!`red`blue`shiny`concave`corroded

`blue`red`shiny`concave`corroded~m a@*&399=f'a:(!m)p 5

/ modified ackermann
/ m n
/ 0 n+1
/ 1 1+n+R8
/ 2 1+n+R8*n+2

/ http://kx.com/q/bell.q
a:{$[x;.z.s[x-1;$[y;.z.s[x;y-1];1]];y+1]}
/ http://home.versatel.nl/vspickelen/Largefiles/Ackerman.htm
a:{[s;m;n];s[t:1]:m;while[t;m:s t;t-:1;n:$[m=0;n+1;n=0;[s[t+:1]:m-1;1];[s[t+:1]:m-1;s[t+:1]:m;n-1]]];n}
/ modified ackerman
a:{[s;R8;m;n]s[t:1]:m;while[t;m:s t;t-:1;n:$[m=0;M15 n+1;m=1;M15 n+R8+1;m=2;M15 1+n+R8*n+2;n=0;[s[t+:1]:m-1;R8];[s[t+:1]:m-1;s[t+:1]:m;n-1]]];n}

6i~a[28608#0;25734i;4;1] / R8:25734i

/ vault
/ * 8 - 1
/ 4 * 11*
/ + 4 - 18
/   - 9 *
30=22 {y[0][x;y 1]}/ 0N 2#(+;4;-;11;*;4;-;18;-;11;-;1)

/ Local Variables:
/ q-msg-prefix: "k)"
/ End:



























