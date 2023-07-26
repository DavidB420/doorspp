format pe64 efi
entry main

section '.text' executable readable

main:
;Save EFI system table that is loaded into rdx
mov qword [efiSystemTable],rdx
mov rsi,welcomeStr
call printString
;Infinite Loop for now
cli
jmp $
ret

printString:
push rdx
push rcx
push rax
push rsi
;Get ConOut in rcx, then use that to get the pointer for the OutputString function in rax 
mov rdx,qword [efiSystemTable]
mov rcx,[rdx+64]
mov rax,[rcx+8]
xchg rdx,rsi
;Setup shadow space for GPRs
sub rsp,32
call rax
add rsp,32
pop rsi
pop rax
pop rcx
pop rdx
ret

section '.data' readable writable

welcomeStr du 'Doors++ UEFI bootloader', 0xD, 0xA, 0
efiSystemTable dq 0