# Synacor Challenge

## The Challenge

Given a [binary file](challenge.bin) and
[architecture specification](arch-spec) implement a
[virtual machine](vm.k) to execute the binary and solve the
[challenges](https://challenge.synacor.com/) that lie within.

## The Solution

This solution was implemented in
[k4](https://en.wikipedia.org/wiki/K_(programming_language)) (the
underlying language of the more popular/verbose
[q](https://en.wikipedia.org/wiki/Q_(programming_language_from_Kx_Systems)))

The solution can be run by starting the virtual machine with the
[q binary](https://kx.com/software-download.php) and passing an
optional file listing the commands to run.  If no file is provided,
[commands.txt](commands.txt) is used.

```sh
$ q vm.k [commands.txt]
```
To issue `k` (instead of `q`) commands to the interpreter, we must
type an initial backslash

```q
q)\

```

## The Design

### memory

The challenge defines three types of memory:

1. memory with 15-bit address space storing 16-bit values
2. eight registers
3. an unbounded stack which holds individual 16-bit values

This specification allows us to model memory as a single integer
vector where:

- the first 32768 addresses are reserved for opcodes loaded from the
  [binary](challenge.bin)
- the next eight addresses (32769-32776) are reserved for the
  registers
- and all remaining elements, dynamically appended or dropped, are
  used for the stack

This solution stores the vector of bytes in the variable `b`.

### addresses

The opcodes loaded from the [binary](challenge.bin) are 16-bit values
stored as little-endian pairs (low byte, high byte). Under normal
conditions, we would load the file with a single call to
[1:](http://code.kx.com/wiki/Reference/OneColon):

```k
  *(1#"h";1#2)1:`challenge.bin
21 21 19 87 19 101 19 108 19 99 19 111 19 109 19 101 19 32 19 116 19 111 19 3..
```

But this assumes the 16-bit values are signed values that range from
-32,768 through 32,767.

`K` does not have an unsigned integer data type. At first glance, this
does not seems to matter because the specification states that literal
values range from 0 - 32,767.  But the eight registers are referenced
with values between 32768 - 32775. We must therefore load the bytes as
32-bit integers. To do this, we reshape the byte vector into pairs of
bytes, pad each pair with 2 extra bytes `0x0000`, and convert the
resulting 8-byte vectors into a 32-bit integers.

```k
  |(0x0/:0x0000,)'0N 2#|1:`challenge.bin
21 21 19 87 19 101 19 108 19 99 19 111 19 109 19 101 19 32 19 116 19 111 19 3..
```

The final step pads the vector to address 32,775 so the stack can
begin at address 32,776.

```k
  32776#|(32776#0i),(0x0/:0x0000,)'0N 2#|1:`challenge.bin
21 21 19 87 19 101 19 108 19 99 19 111 19 109 19 101 19 32 19 116 19 111 19 3..
```

### opcodes

All operations are implemented to accept a single memory address as
input and return the next executable address as output.  For example,
the `jt` opcode (jump to address located in x+1 if the value in
address x is true, and x+2 otherwise) is defined as:

```k
JT:{$[G x;G x+1;x+2]}
```

To map the opcodes (which range in value from 0 through 21) to
operators, we construct a vector of operator names. This
solution stores them in the variable `o`.

```k
o:`HALT`SET`PUSH`POP`EQ`GT`JMP`JT`JF`ADD`MULT`MOD`AND`OR`NOT`RMEM`WMEM`CALL`RET`OUT`IN`NOOP
```

Indexing into `o` produces the correct operator name, which `k` allows
us to use in-place of the actual operator. `K` will perform the lookup
for us.

### execution

We define the operator `E` to accept an address which is used to query
the opcode for the next operation.  The operator is obtained and
passed the next address.

```k
E:{o[G x]x+1}
```

Forcing operators to accept (and return) an address allows us to execute
a single operation,

```k
  E 1
2
```

a set number of operations by iterating with a numeric left operand,

```k
  35 E/ 1
Welcome to the Synacor Challenge!
70
```

or a variable number of operations by iterating with a condition as
the left operand.

```k
  (~0=) E/ 1
```

In this case, operations are executed until the address returned is 0
(which we have designed the `halt` operator to return). We can start
the iteration at address 1 and safely rely on 0 to terminate the
iteration because the opcode in the first address is defined as
`noop`.

### debugging

It is often necessary to view the values stored in the eight registers
as well as those on the stack. Two
[views](http://code.kx.com/wiki/Views) are defined to make this
easier: `REG` and `STACK`.

```k
  REG
25975 25974 26006 0 101 0 0 25734i
  STACK
6080 16 6124 1 2826 32 3 6 101 0i
```
## The Puzzles

The challenge begins by performing a self-test to exercise each of the
operators.  Passing this stage is an accomplishment in and of itself.
But the challenge hasn't even begun.  I will, of course, leave that to
you.

You must discover (and submit) 8 codes to complete the challenge. The
first code can be found in the
[architecture specification](arch-spec).  The second code is displayed
after implementing opcodes 0, 19 and 21 (as suggested in the
specification). Successfully implementing the remaining opcodes
reveals the third code.

Five more codes are discovered by solving the remaining puzzles:

- the maze
- the ruins
- the teleporter
- the vault
- the mirror


## The Prize

The challenge was designed to attract competent programmers.
Successfully completing the challenge may get you an interview at
Synacor.  For me, completing the challenge was prize enough. The
closing [screenshot](Screen Shot 2016-01-16 at 9.37.19 AM.png) is an
awesome souvenir.
