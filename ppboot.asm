format pe64 efi
entry main

section '.text' executable readable

include 'uefi.inc'

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
;Setup GOP
call setupGOP
;Exit boot services
;Move file to proper memory address
mov rax,[efiOSBufferHandle]
mov rcx,[efiReadSize]
;repe movsb
;Infinite Loop for now
cli
jmp $
ret

setupGOP:
;Get GOP pointer
lea rcx,[gopguid]
mov rdx,0
lea r8,[efiGOPHandle]
mov r9,qword [efiSystemTable]
mov r9,[r9+EFI_SYSTEM_TABLE.BootServices]
call qword [r9+EFI_BOOT_SERVICES_TABLE.LocateProtocol]
;Query number of video modes
mov rax,[efiGOPHandle]
mov rax,[rax+EFI_GRAPHICS_OUTPUT_PROTOCOL.Mode]
mov ecx,dword [rax+EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE.MaxMode]
and ecx,ecx
dec rcx
loopgetgopmodes:
push rcx
mov rdx,rcx
mov rcx,[efiGOPHandle]
lea r8,[gopModeSize]
mov r9,gopModeInfo
call qword [rcx+EFI_GRAPHICS_OUTPUT_PROTOCOL.QueryMode]
pop rcx
loop loopgetgopmodes
mov r9,gopModeInfo
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
;Get volume handle
mov rcx,[efiLoadedImage]
mov rcx,[rcx+EFI_LOADED_IMAGE_PROTOCOL.DeviceHandle]
mov rdx,EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID
lea r8,[efiVolumeHandle]
mov r9,qword [efiSystemTable]
mov r9,[r9+EFI_SYSTEM_TABLE.BootServices]
call qword [r9+EFI_BOOT_SERVICES_TABLE.HandleProtocol]
;Open Volume
mov rcx,[efiVolumeHandle]
lea rdx,[efiRootFSHandle]
call qword [rcx+EFI_SIMPLE_FILE_SYSTEM_PROTOCOL.OpenVolume]
ret

openFile:
;Open file and check if file loaded successfully
mov rcx,[efiRootFSHandle]
lea rdx,[efiFileHandle]
mov r9,EFI_FILE_MODE_READ
call qword [rcx+EFI_FILE_PROTOCOL.Open]
cmp rax,0
je skiperrorloadingkernel
mov rsi,errorStr
call printString
call waitForAnyKey
mov al,0xfe
out 0x64,al
skiperrorloadingkernel:
;Allocate memory pool
mov rcx,2
mov rdx,qword [efiReadSize]
lea r8,[efiOSBufferHandle]
mov r9,qword [efiSystemTable]
mov r9,[r9+EFI_SYSTEM_TABLE.BootServices]
call qword [r9+EFI_BOOT_SERVICES_TABLE.AllocatePool]
;Read file
mov rcx,[efiFileHandle]
lea rdx,[efiReadSize]
mov r8,[efiOSBufferHandle]
call qword [rcx+EFI_FILE_PROTOCOL.Read]
ret

waitForAnyKey:
mov rdx,1
mov rcx,[efiSystemTable]
mov rcx,[rcx+EFI_SYSTEM_TABLE.ConIn]
call qword [rcx+EFI_SIMPLE_TEXT_INPUT_PROTOCOL.Reset]
loopwaitforkeypress:
lea rdx,[efiKeyData]
mov rcx,[efiSystemTable]
mov rcx,[rcx+EFI_SYSTEM_TABLE.ConIn]
call qword [rcx+EFI_SIMPLE_TEXT_INPUT_PROTOCOL.ReadKeyStroke]
and rax,0xff
cmp rax,6 ;Check if its not ready
je loopwaitforkeypress
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
errorStr du 'Error loading PPLDR.SYS!', 0xd, 0xa, 'Press any key to reboot...',0
ldrFN du 'ppldr.sys',0
efiSystemTable dq 0
efiLoadedImage dq 0
efiImageHandle dq 0
efiDevicePathHandle dq 0
efiVolumeHandle dq 0
efiRootFSHandle dq 0
efiFileHandle dq 0
efiOSBufferHandle dq 0
efiGOPHandle dq 0
efiReadSize dq 1216
efiKeyData dq 0
EFI_LOADED_IMAGE_PROTOCOL_GUID db 0xa1, 0x31, 0x1b, 0x5b, 0x62, 0x95, 0xd2, 0x11, 0x8e, 0x3f, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b
EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID db 0x22, 0x5b, 0x4e, 0x96, 0x59, 0x64, 0xd2, 0x11, 0x8e, 0x39, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b
blockiouuid db EFI_BLOCK_IO_PROTOCOL_UUID
gopguid db EFI_GRAPHICS_OUTPUT_PROTOCOL_UUID
gopMax dd 0
gopModeSize dq 0
gopModeInfo dd 0,0,0,0,0,0,0,0
EFI_FILE_MODE_READ = 0x0000000000000001
secondStageLoc = 0x030000