module gen

import token
import parse

const opcodes = [
	u8(0x00),
	0x01,
	0x02,
	0x05,
	0x06,
	0x08,
	0x09,
	0x0A,
	0x0D,
	0x0E,

	0x10,
	0x11,
	0x15,
	0x16,
	0x18,
	0x19,
	0x1D,
	0x1E,

	0x20,
	0x21,
	0x24,
	0x25,
	0x26,
	0x28,
	0x29,
	0x2A,
	0x2C,
	0x2D,
	0x2E,

	0x30,
	0x31,
	0x35,
	0x36,
	0x38,
	0x39,
	0x3D,
	0x3E,

	0x40,
	0x41,
	0x45,
	0x46,
	0x48,
	0x49,
	0x4A,
	0x4C,
	0x4D,
	0x4E,

	0x50,
	0x51,
	0x55,
	0x56,
	0x58,
	0x5D,
	0x5E,

	0x60,
	0x61,
	0x65,
	0x66,
	0x68, 
	0x69,
	0x6A,
	0x6C,
	0x6D,
	0x6E,

	0x70,
	0x71,
	0x75,
	0x76,
	0x78,
	0x79,
	0x7D,
	0x7E,

	0x81,
	0x84,
	0x85,
	0x86,
	0x88,
	0x8A,
	0x8C,
	0x8D,
	0x8E,

	0x90,
	0x91,
	0x94,
	0x95,
	0x96,
	0x98,
	0x99,
	0x9A,
	0x9D,

	0xA0,
	0xA1,
	0xA2,
	0xA4,
	0xA5,
	0xA6,
	0xA8,
	0xA9,
	0xAA,
	0xAC,
	0xAD,
	0xAE,

	0xB0,
	0xB1,
	0xB4,
	0xB5,
	0xB6,
	0xB8,
	0xB9,
	0xBA,
	0xBC,
	0xBD,
	0xBE,

	0xC0,
	0xC1,
	0xC4,
	0xC5,
	0xC6,
	0xC8,
	0xC9,
	0xCA,
	0xCC,
	0xCD,
	0xCE,

	0xD0,
	0xD1,
	0xD5,
	0xD6,
	0xD8,
	0xD9,
	0xDD,
	0xDE,

	0xE0,
	0xE1,
	0xE4,
	0xE5,
	0xE6,
	0xE8,
	0xE9,
	0xEA,
	0xEC,
	0xED,
	0xEE,
	
	0xF0,
	0xF1,
	0xF5,
	0xF6,
	0xF8,
	0xF9,
	0xFD,
	0xFE
]

// all the Branching instructions are absolute.
// they look the same to the parser, but do not overlap
// with instructions that use absolute addressing
// so it's fine to keep it that way.
const insts = [
	// 0x0x
	Inst{.brk, .implied, 0},
	Inst{.ora, .xzero_page_indirect, 0},
	Inst{.kil, .implied, 0},
	Inst{.ora, .zero_page, 0},
	Inst{.asl, .zero_page, 0},
	Inst{.php, .implied, 0},
	Inst{.ora, .immediate, 0},
	Inst{.asl, .accumulator, 0},
	Inst{.ora, .absolute, 0},
	Inst{.asl, .absolute, 0},
	// 0x1x
	Inst{.bpl, .absolute, 0},
	Inst{.ora, .yindirect_zero_page, 1},
	Inst{.ora, .index_zero_page, 0},
	Inst{.asl, .index_zero_page, 0},
	Inst{.clc, .implied, 0},
	Inst{.ora, .index_absolute, 1},
	Inst{.ora, .index_absolute, 0},
	Inst{.asl, .index_absolute, 0},
	// 0x2x
	Inst{.jsr, .absolute, 0},
	Inst{.and, .xzero_page_indirect, 0},
	Inst{.bit, .zero_page, 0},
	Inst{.and, .zero_page, 0},
	Inst{.rol, .zero_page, 0},
	Inst{.plp, .implied, 0},
	Inst{.and, .immediate, 0},
	Inst{.rol, .accumulator, 0},
	Inst{.bit, .absolute, 0},
	Inst{.and, .absolute, 0},
	Inst{.rol, .absolute, 0},
	// 0x3x
	Inst{.bmi, .absolute, 0},
	Inst{.and, .yindirect_zero_page, 1},
	Inst{.and, .index_zero_page, 0},
	Inst{.rol, .index_zero_page, 0},
	Inst{.sec, .implied, 0},
	Inst{.and, .index_absolute, 1},
	Inst{.and, .index_absolute, 0},
	Inst{.rol, .index_absolute, 0},
	// 0x4x
	Inst{.rti, .implied, 0},
	Inst{.eor, .xzero_page_indirect, 0},
	Inst{.eor, .index_zero_page, 0},
	Inst{.lsr, .index_zero_page, 0},
	Inst{.pha, .implied, 0},
	Inst{.eor, .immediate, 0},
	Inst{.lsr, .accumulator, 0},
	Inst{.jmp, .absolute, 0},
	Inst{.eor, .absolute, 0},
	Inst{.lsr, .absolute, 0},
	// 0x5x
	Inst{.bvc, .absolute, 0},
	Inst{.eor, .yindirect_zero_page, 1},
	Inst{.eor, .index_zero_page, 0},
	Inst{.lsr, .index_zero_page, 0},
	Inst{.cli, .implied, 0},
	Inst{.eor, .index_absolute, 1},
	Inst{.eor, .index_absolute, 0},
	Inst{.lsr, .index_absolute, 0},
	// 0x6x
	Inst{.rts, .implied, 0},
	Inst{.adc, .xzero_page_indirect, 0},
	Inst{.adc, .zero_page, 0},
	Inst{.ror, .zero_page, 0},
	Inst{.pla, .implied, 0},
	Inst{.adc, .immediate, 0},
	Inst{.jmp, .absolute_indirect, 0},
	Inst{.eor, .absolute, 0},
	Inst{.lsr, .absolute, 0},
	// 0x7x
	Inst{.bvs, .absolute, 0},
	Inst{.adc, .yindirect_zero_page, 1},
	Inst{.adc, .index_zero_page, 0},
	Inst{.ror, .index_zero_page, 0},
	Inst{.sei, .implied, 0},
	Inst{.adc, .index_absolute, 1},
	Inst{.adc, .index_absolute, 0},
	Inst{.ror, .index_absolute, 0},
	// 0x8x
	Inst{.sta, .xzero_page_indirect, 0},
	Inst{.sty, .zero_page, 0},
	Inst{.sta, .zero_page, 0},
	Inst{.stx, .zero_page, 0},
	Inst{.dey, .implied, 0},
	Inst{.txa, .implied, 0},
	Inst{.sty, .absolute, 0},
	Inst{.sta, .absolute, 0},
	Inst{.stx, .absolute, 0},
	// 0x9x
	Inst{.bcc, .absolute, 0},
	Inst{.sta, .yindirect_zero_page, 1},
	Inst{.sty, .index_zero_page, 0},
	Inst{.sta, .index_zero_page, 0},
	Inst{.stx, .index_zero_page, 1},
	Inst{.tya, .implied, 0},
	Inst{.sta, .index_absolute, 1},
	Inst{.txs, .implied, 0},
	// 0xAx
	Inst{.ldy, .immediate, 0},
	Inst{.lda, .xzero_page_indirect, 0},
	Inst{.ldx, .immediate, 0},
	Inst{.ldy, .zero_page, 0},
	Inst{.lda, .zero_page, 0},
	Inst{.ldx, .zero_page, 0},
	Inst{.tay, .implied, 0},
	Inst{.lda, .immediate, 0},
	Inst{.tax, .implied, 0},
	Inst{.ldy, .absolute, 0},
	Inst{.lda, .absolute, 0},
	Inst{.ldx, .absolute, 0},
	// 0xBx
	Inst{.bcs, .absolute, 0},
	Inst{.lda, .yindirect_zero_page, 1},
	Inst{.ldy, .index_zero_page, 0},
	Inst{.lda, .index_zero_page, 0},
	Inst{.ldx, .index_zero_page, 1},
	Inst{.clv, .implied, 0},
	Inst{.lda, .index_absolute, 1},
	Inst{.tsx, .implied, 0},
	Inst{.ldy, .index_absolute, 0},
	Inst{.lda, .index_absolute, 0},
	Inst{.ldx, .index_absolute, 1},
	// 0xCx
	Inst{.cpy, .immediate, 0},
	Inst{.cmp, .xzero_page_indirect, 0},
	Inst{.cpy, .zero_page, 0},
	Inst{.cmp, .zero_page, 0},
	Inst{.dec, .zero_page, 0},
	Inst{.iny, .implied, 0},
	Inst{.cmp, .immediate, 0},
	Inst{.dex, .implied, 0},
	Inst{.cpy, .absolute, 0},
	Inst{.cmp, .absolute, 0},
	Inst{.dec, .absolute, 0},
	// 0xDx
	Inst{.bne, .absolute, 0},
	Inst{.cmp, .yindirect_zero_page, 1},
	Inst{.cmp, .index_zero_page, 0},
	Inst{.dec, .index_zero_page, 0},
	Inst{.cld, .implied, 0},
	Inst{.cmp, .index_absolute, 1},
	Inst{.cmp, .index_absolute, 0},
	Inst{.dec, .index_absolute, 0},
	// 0xEx
	Inst{.cpx, .immediate, 0},
	Inst{.sbc, .xzero_page_indirect, 0},
	Inst{.cpx, .zero_page, 0},
	Inst{.sbc, .zero_page, 0},
	Inst{.inc, .zero_page, 0},
	Inst{.inx, .implied, 0},
	Inst{.sbc, .immediate, 0},
	Inst{.nop, .implied, 0},
	Inst{.cpx, .absolute, 0},
	Inst{.sbc, .absolute, 0},
	Inst{.inc, .absolute, 0},
	// 0xFx
	Inst{.beq, .absolute, 0},
	Inst{.sbc, .yindirect_zero_page, 1},
	Inst{.sbc, .index_zero_page, 0},
	Inst{.inc, .index_zero_page, 0},
	Inst{.sed, .implied, 0},
	Inst{.sbc, .index_absolute, 1},
	Inst{.sbc, .index_absolute, 0},
	Inst{.inc, .index_absolute, 0}
]

struct Inst {
	a token.Kind
	b parse.AddressingMode
	c u8 // register
}

struct Label {
	a u16 // location
	b string // name
}

[direct_array_access]
pub fn gen(nodes []parse.Node) []u8 {
	mut s := []u8{}
	mut labels := []Label{}

	for node in nodes {
		
		inst := Inst{node.inst, node.mode, node.register}

		if node.node == .label {
		// adjust for stack and zero page and inst
			labels << Label {u16(s.len)+0x1FF+1, node.label}
			continue
		}

		if node.mode in [.absolute, .absolute_indirect, .index_absolute] && node.label != '' && node.operand == 0 {
			// we already know the label exists
			for l in labels {
				// if label.b matches node.label, the address becomes label.b
				if l.b == node.label {
					s << opcodes[insts.index(inst)]
					s << u8(l.a)
					s << u8(l.a >> 8)
				}
			}

			continue // the outer loop
		}

		match node.mode {
			.implied, .accumulator {
				s << opcodes[insts.index(inst)]
				continue
			}
			.immediate {
				s << opcodes[insts.index(inst)]
				s << u8(node.operand)
				continue
			}
			.absolute, .absolute_indirect, .index_absolute {
				s << opcodes[insts.index(inst)]
				s << u8(node.operand)
				s << u8(node.operand >> 8)
				continue
			}
			.zero_page, .yindirect_zero_page, .xzero_page_indirect, .index_zero_page {
				s << opcodes[insts.index(inst)]
				s << u8(node.operand)
				continue
			}
			else { continue }
		}

	}

	if s.len > (1 << 16) {
		eprintln('your program is too big: expected a maximum of 65536 bytes but got ${s.len} bytes')
		exit(1)
	}

	return s
}