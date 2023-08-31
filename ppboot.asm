format pe64 efi
entry main

section '.text' executable readable

main:
;Save EFI system table that is loaded into rdx
mov qword [efiSystemTable],rdx
mov qword [efiImageHandle],rcx
;Output welcome message
mov rsi,welcomeStr
call printString
;Begin to load the file system
call initEfiFileSystem
mov r8,ldrFN
call openFile
;Infinite Loop for now
cli
jmp $
ret

initEfiFileSystem:
;Get loaded image pointer
mov rcx,[efiImageHandle]
mov rdx,EFI_LOADED_IMAGE_PROTOCOL_GUID
lea r8,[efiLoadedImage]
mov r9,qword [efiSystemTable]
mov r9,[r9+EFI_SYSTEM_TABLE.BootServices]
call qword [r9+EFI_BOOT_SERVICES_TABLE.HandleProtocol]
;Get device path handle
mov rcx,[efiLoadedImage]
mov rcx,[rcx+24]
mov rdx,EFI_DEVICE_PATH_PROTOCOL_GUID
lea r8,[efiDevicePathHandle]
mov r9,qword [efiSystemTable]
mov r9,[r9+EFI_SYSTEM_TABLE.BootServices]
call qword [r9+EFI_BOOT_SERVICES_TABLE.HandleProtocol]
;Get volume handle
mov rcx,[efiLoadedImage]
mov rcx,[rcx+24]
mov rdx,EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID
lea r8,[efiVolumeHandle]
mov r9,qword [efiSystemTable]
mov r9,[r9+EFI_SYSTEM_TABLE.BootServices]
call qword [r9+EFI_BOOT_SERVICES_TABLE.HandleProtocol]
ret

openFile:
push r8
;Open Volume
mov rcx,[efiVolumeHandle]
lea rdx,[efiRootFSHandle]
call qword [rcx+EFI_SIMPLE_FILE_SYSTEM_PROTOCOL.OpenVolume]
;Open file
mov rcx,[efiRootFSHandle]
lea rdx,[efiFileHandle]
pop r8
mov r9,EFI_FILE_MODE_READ
mov qword[rsp + 8*4], 0
call qword [rcx+EFI_FILE_PROTOCOL.Open]
;Allocate memory pool
mov rcx,2
mov rdx,0x0030000
lea r8,[efiOSBufferHandle]
mov r9,qword [efiSystemTable]
mov r9,[r9+EFI_SYSTEM_TABLE.BootServices]
call qword [r9+EFI_BOOT_SERVICES_TABLE.AllocatePool]
;Read file
mov rcx,[efiFileHandle]
mov rdx,0x0030000
mov r8,[efiOSBufferHandle]
call qword [rcx+EFI_FILE_PROTOCOL.Read]
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
ldrFN du 'ppldr.sys',0
efiSystemTable dq 0
efiLoadedImage dq 0
efiImageHandle dq 0
efiDevicePathHandle dq 0
efiVolumeHandle dq 0
efiRootFSHandle dq 0
efiFileHandle dq 0
efiOSBufferHandle dq 0
EFI_LOADED_IMAGE_PROTOCOL_GUID db 0xa1, 0x31, 0x1b, 0x5b, 0x62, 0x95, 0xd2, 0x11, 0x8e, 0x3f, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b
EFI_DEVICE_PATH_PROTOCOL_GUID db 0x91, 0x6e, 0x57, 0x09, 0x3f, 0x6d, 0xd2, 0x11, 0x8e, 0x39, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b
EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID db 0x22, 0x5b, 0x4e, 0x96, 0x59, 0x64, 0xd2, 0x11, 0x8e, 0x39, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b
EFI_FILE_MODE_READ = 0x0000000000000001
include 'uefi.inc'