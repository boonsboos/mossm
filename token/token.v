module token

import regex

const keyword_map = {
	"ADC" : Kind.adc
	"AND" : .and
	"ASL" : .asl
	"BCC" : .bcc
	"BCS" : .bcs
	"BEC" : .bec
	"BIT" : .bit 
	"BMI" : .bmi
	"BNE" : .bne
	"BPL" : .bpl
	"BRK" : .brk
	"BVS" : .bvs
	"CLC" : .clc
	"CLD" : .cld
	"CLI" : .cli
	"CLV" : .clv
	"CMP" : .cmp
	"CPX" : .cpx
	"CPY" : .cpy
	"DEC" : .dec
	"DEX" : .dex
	"DEY" : .dey
	"EOR" : .eor
	"INC" : .inc
	"INX" : .inx
	"INY" : .iny
	"JMP" : .jmp
	"JSR" : .jsr
	"KIL" : .kil
	"LDA" : .lda
	"LDX" : .ldx
	"LDY" : .ldy
	"LSR" : .lsr
	"NOP" : .nop
	"ORA" : .ora
	"PHA" : .pha
	"PHP" : .php
	"PLA" : .pla
	"PLP" : .plp
	"ROL" : .rol
	"ROR" : .ror
	"RTI" : .rti
	"RTS" : .rts
	"SBC" : .sbc
	"SEC" : .sec
	"SED" : .sed
	"SEI" : .sei
	"STA" : .sta
	"STX" : .stx
	"STY" : .sty
	"TAX" : .tax
	"TAY" : .tay
	"TXA" : .txa
	"TXS" : .txs
	"TYA" : .tya
}

pub enum Kind {
	adc
	and
	asl
	bcc
	bcs
	bec
	bit
	bmi
	bne
	bpl
	brk
	bvc
	bvs
	clc
	cld
	cli
	clv
	cmp
	cpx
	cpy
	dec
	dex
	dey
	eor
	inc
	inx
	iny
	jmp
	jsr
	kil
	lda
	ldx
	ldy
	lsr
	nop
	ora
	pha
	php
	pla
	plp
	rol
	ror
	rti
	rts
	sbc
	sec
	sed
	sei
	sta
	stx
	sty
	tax
	tay
	tsx
	txa
	txs
	tya
	// now actual token stuff
	literal
	dollar
	hash
	comma
	colon
	ident
}

pub struct Token {
	inst Kind
	real string
	row int
	col int
}

[direct_array_access]
pub fn tokenize(file string) []Token {

	mut number_regex := regex.regex_opt('^[0-9A-Fa-f][0-9A-Fa-f]') or { panic('failed to construct regex') }
    mut ident_regex  := regex.regex_opt('^_?[A-Za-z_]+') or { panic('failed to construct regex') }
	mut comment_regex := regex.regex_opt('^;.+\n') or { panic('failed to construct regex') }

	mut tokens := []Token{}

	mut idx := 0
	mut row := 1
	mut col := 1

	for idx < file.len {

		if file[idx].ascii_str() == "\n" {
			row++
			idx++
			continue
		}

		if file[idx].ascii_str() in ["\t","\v"," "] {
			idx++
			col++
			continue
		}

		if t := keyword_map[file[idx..idx+3]] {
			tokens << Token{t, file[idx..idx+3], row, col}
			col += 3
			idx += 3
			continue
		}

		match file[idx].ascii_str() {
			// comments
			';' {
				row++
				l, r := comment_regex.find(file[idx..])
				if l > -1 {
					idx += r
				}
				continue
			}
			',' {
				tokens << Token{.comma, ',', row, col}
				col++
				idx++
				continue
			}
			'#' {
				tokens << Token{.hash, '#', row, col}
				col++
				idx++
				continue
			}
			':' {
				tokens << Token{.colon, ':', row, col}
				col++
				idx++
				continue
			}
			'$' {
				tokens << Token{.dollar, '$', row, col}
				col++
				idx++
				continue
			}
			else {}
		}

		// number literal
		number_l, _ := number_regex.find(file[idx..idx+2])
		if number_l > -1 {
			tokens << Token{.literal, file[idx..idx+2], row, col}
			col += 2
			idx += 2
			continue
		}

		ident_l, ident_r := ident_regex.find(file[idx..])
		if ident_l > -1 {
			tokens << Token{.ident, file[idx..idx+ident_r], row, col}
			col += ident_r
			idx += ident_r
			continue
		}

	}

	return tokens
}