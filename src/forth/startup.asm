[section .startup]

global startup
global startup_len
startup:
incbin "src/startup.f"
startup_len: dd $-startup

; vi: cc=80 ft=nasm
