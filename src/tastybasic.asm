
#ifdef zemu
tty_data        .equ 7ch                ; Z80 Emulator
tty_status      .equ 7dh
rx_full         .equ 1
tx_empty        .equ 0
#else
; tty_data        .equ 67h              ; SBC V2
; tty_status      .equ 68h
; rx_full         .equ 1
; tx_empty        .equ 0
#endif

lf              .equ 0ah
cr              .equ 0dh

                .org 0h

start:
                call crlf
                ld a,'>'
                call uart_tx
                ld a,' '
                call uart_tx
                call uart_rx
                call uart_tx
                jp start

crlf:
                push af
                ld a,cr
                call uart_tx
                ld a,lf
                call uart_tx
                pop af
                ret

uart_rx:
                call uart_rx_ready
                in a,(tty_data)
                ret
uart_rx_ready:
                push af
uart_rx_ready_loop:
                in a,(tty_status)
                bit rx_full,a
                jp z,uart_rx_ready_loop
                pop af
                ret

uart_tx:
                call uart_tx_ready
                out (tty_data),a
                ret
uart_tx_ready:
                push af
uart_tx_ready_loop:
                in a,(tty_status)
                bit tx_empty,a
                jp z,uart_tx_ready_loop
                pop af
                ret

                .end
