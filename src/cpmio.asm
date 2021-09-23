; -----------------------------------------------------------------------------
; Copyright 2021 Dimitri Theulings
;
; This file is part of Tasty Basic.
;
; Tasty Basic is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; Tasty Basic is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Tasty Basic.  If not, see <https://www.gnu.org/licenses/>.
; -----------------------------------------------------------------------------
; Tasty Basic is derived from earlier works by Li-Chen Wang, Peter Rauskolb,
; and Doug Gabbard. Refer to the source code repository for details
; <https://github.com/dimitrit/tastybasic/>.
; -----------------------------------------------------------------------------

USRPTR_OFFSET			.equ 09feh
USRFUNC_OFFSET			.equ 0a00h
INTERNAL_OFFSET			.equ 0b00h
TEXTEND_OFFSET			.equ 07cffh
STACK_OFFSET			.equ 07effh

BDOS				.equ 05h				; standard cp/m entry
DCONIO				.equ 06h				; direct console I/O
INPREQ				.equ 0ffh				; console input request

haschar:	
				push	bc
				push	de
				ld	c,DCONIO			; direct console i/o
				ld	e,INPREQ			; input request
				call	BDOS				; any chr typed?
				pop	de				; if yes, (a)<--char
				pop	bc				; else    (a)<--00h (ignore chr)
				or	a				
				ret
;
putchar:					
				push	bc
				push	de
				push	af
				push	hl
				ld	c,DCONIO			; direct console i/o
				ld	e,a				; output char (a)
				call	BDOS
				pop	hl
				pop	af
				pop	de
				pop	bc
				ret
bye:
				jp 0					; does not return!