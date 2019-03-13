: immediate forth-last-word @ forth-cfa 9 - dup c@ 1 or swap c! ;

: lw forth-last-word ;

: rot >r swap r> swap ;
: -rot swap >r swap  r> ;

: over >r dup r> swap ;
: 2drop drop drop ;

: allot forth-dp @ swap over + forth-dp ! ;
: here forth-here @ ;
: <> = not ;
: <= 2dup < -rot =  lor ;
: > <= not ;
: >= < not ;

: cell% 8 ;
: cells cell% * ;
: KB 1024 * ;
: MB KB KB  ;

: begin here ; immediate
: again ' branch , , ; immediate

: if ' 0branch , here 0  , ; immediate
: else ' branch , here 0 , swap here swap !  ; immediate
: then here swap ! ; immediate
: endif ' then execute ; immediate

: repeat here ; immediate
: until  ' 0branch , , ; immediate
: for
  ' swap ,
  ' >r ,
  ' >r ,
  here  ' r> ,
  ' r> ,
  ' 2dup ,
  ' >r ,
  ' >r ,
  ' < ,
  ' 0branch ,
  here    0 ,
  swap ; immediate

: endfor
  ' r> ,
  ' lit , 1 ,
  ' + ,
  ' >r ,
  ' branch ,
  ,  here swap !
  ' r> ,
  ' drop ,
  ' r> ,
  ' drop ,

; immediate

: do  ' swap , ' >r , ' >r ,  here ; immediate

: loop
  ' r> ,
  ' lit , 1 ,
  ' + ,
  ' dup ,
  ' r@ ,
  ' < ,
  ' not ,
  '  swap ,
  ' >r ,
  ' 0branch , ,
  ' r> ,
  ' drop ,
  ' r> ,
  ' drop ,
;  immediate

: STDIN  0 ;
: STDOUT 1 ;
: STDERR 2 ;
: read-char forth-input-fd @ file-read-char ;
: print-char STDOUT swap file-write-char ; 
: ( repeat read-char if 41 = else 1 then until ; immediate

: forth-compile-number forth-is-compiling @ if ' lit , , then ; 
: char-code-of read-char if forth-compile-number then  ; immediate
: digit-to-char char-code-of 0 + ;
: char-to-digit char-code-of 0 - ;

( a1 a2 - )
: swap@
  over c@ >r ( a1 a2, x1 ; )
  2dup c@ swap c! ( a1 a2, x1; x2 -> a1 )
  r> swap c! drop
;

: dec 1 - ;

( str - )
: string-reverse
  dup dup string-length + dec ( beg end )
  repeat
    2dup swap@ dec swap inc swap 2dup >
  until
  2drop 
;


: QUOTE 34 ;

: " forth-is-compiling @ if
      ' branch , here 0 , here
      repeat
      read-char if dup QUOTE = if drop
          0 c,
          swap here swap !
          ' lit , , 1
          else c, 0 then
          else
            0 c,
            swap here swap !
            ' lit , , 1
          then
      until
    else
      repeat
      read-char if dup QUOTE = if drop 1 else print-char 0 then else 1 then
      until
    then ; immediate


: ." ' " execute forth-is-compiling @ if ' print-string , then ; immediate
: // print-cr ;

( buf num - )
: string-unsigned-number
  over >r >r
  ( buf, buf num )
  repeat
    r@ 10 % digit-to-char over c!
    inc r> 10 / >r
    r@ not
until
drop r> drop r> string-reverse ;

( buf num - )
: string-signed-number
  dup 0 < if
    swap dup char-code-of - swap c!
    inc swap neg
  then
  string-unsigned-number ;

: print-signed-number 3 cells allot dup >r swap string-signed-number r> print-string ;
: print-unsigned-number 3 cells allot dup >r swap string-unsigned-number r> print-string ;
: . print-signed-number ;


: .S
  sp 
repeat
  dup forth-stack-start @ < if
    dup @ . //
    cell% + 0
  else drop 1 then
until ;

." Forthress 2 -- a tiny Forth from scratch > (c) Igor Zhirkov 2019 " //

