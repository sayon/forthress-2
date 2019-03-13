; ------------------------------------------------
; Forthress 2, a Forth dialect 
;
; Author: igorjirkov@gmail.com
; Date  : 08-03-2019
;
; This is the main Forthress 2 file which defines the entry point
; Please define words inside "words.inc"
; ------------------------------------------------

global _start
%include "macro.inc"

%define pc r15
%define w r14
%define rstack r13

section .text

%include "kernel.inc"   ;  Minimal word set is here
%include "words.inc"    ;  Predefined words are here

section .bss

; return stack end-----;
resq 1023              ;
rstack_start: resq 1   ;
; return stack start---;

user_mem: resq 65536   ; global data for user

section .data

last_word: dq _lw      ; stores a pointer to the last word in dictionary
                       ; should be placed after all words are defined
dp: dq user_mem        ; current global data pointer
stack_start:  dq 0     ; stores a saved address for data stack beginning
trap_word_xt: dq 0     ; XT for a word to be called on SIGSEGV

section .text

next:                  ; inner interpreter, fetches next word to execute
    mov w, pc
    add pc, 8
    mov w, [w]
    jmp [w]

_start:
    call setup_trap
    mov rstack, rstack_start
    mov [stack_start], rsp

  ;;  starting arguments:
    push qword 0                ; fid
    mov pc, xt_forth_interpret_fd+8 
    jmp next

; ------------------------------------------------
; This part sets up SIGSEGV handler
; ------------------------------------------------

%define SA_RESTORER 0x04000000
%define SA_SIGINFO  0x00000004
%define __NR_rt_sigaction	0x0D
%define SIGSEGV		0x0B
setup_trap:
		mov r10, 8
		xor rdx, rdx
		mov rsi, sa
		mov	rdi, SIGSEGV
		mov rax,__NR_rt_sigaction
		syscall
        ret

section .rodata
sa:
	.handler  	dq _trap
	.flags		dq SA_RESTORER | SA_SIGINFO
	.restorer	dq 0
	.val	    dq 0
