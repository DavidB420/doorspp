format pe64 dll efi
entry main
section '.text' code executable readable
main:

infiniteLoop:

sub rsp,64

mov r8,Variables
mov [r8],rcx
mov [r8+8],rdx

mov rcx,[rdx+64]
lea rdx,[greetingString]
call qword [rcx+8]

call WaitForKeyPress

add rsp,64

jmp infiniteLoop

ret

WaitForKeyPress:
;mov rcx,[
ret

section '.data' data readable writeable

greetingString du 'Hello World',0

Variables:
EfiHandle dq 0
EfiTable dq 0

section '.reloc' fixups data discardable
