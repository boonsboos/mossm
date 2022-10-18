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


]

// all the Branching instructions are absolute.
// they look the same to the parser, but do not overlap
// with instructions that use absolute addressing
// so it's fine to keep it that way.
const insts = [
	// 0x0x
	Inst{.brk, .implied, 0},
	Inst{.kil, .implied, 0},
	Inst{.ora, .xzero_page_indirect, 0},
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
	Inst{.ora, .index_absolute, 1}
	Inst{.ora, .index_absolute, 0}
	Inst{.asl, .index_absolute, 0}
	// 0x2x
	Inst{.jsr, .absolute, 0}
	Inst{.and, .xzero_page_indirect, 0}
	Inst{.bit, .zero_page, 0}
	Inst{.and, .zero_page, 0}
	Inst{.rol, .zero_page, 0}
	Inst{.plp, .implied, 0}
	Inst{.and, .immediate, 0}
	Inst{.rol, .accumulator, 0}
	Inst{.bit, .absolute, 0}
	Inst{.and, .absolute, 0}
	Inst{.rol, .absolute, 0}
	// 0x3x
	Inst{.bmi, .absolute, 0}
	Inst{.and, .yindirect_zero_page, 1}
	Inst{.and, .index_zero_page, 0}
	Inst{.rol, .index_zero_page, 0}
	Inst{.sec, .implied, 0}
	Inst{.and, .index_absolute, 1}
	Inst{.and, .index_absolute, 0}
	Inst{.rol, .index_absolute, 0}
	// 0x4x
	Inst{.rti, .implied, 0}
	Inst{.eor, .xzero_page_indirect, 0}
	Inst{.eor, .index_zero_page, 0}
	Inst{.lsr, .index_zero_page, 0}
	Inst{.pha, .implied, 0}
	Inst{.eor, .immediate, 0}
	Inst{.lsr, .accumulator, 0}
	Inst{.jmp, .absolute, 0}
	Inst{.eor, .absolute, 0}
	Inst{.lsr, .absolute, 0}
	// 0x5x
	Inst{.bvc, .absolute, 0}
	Inst{.eor, .yindirect_zero_page, 1}
	Inst{.ero, .index_zero_page, 0}
	Inst{.lsr, .index_zero_page, 0}
	Inst{.cli, .implied, 0}
	Inst{.eor, .index_absolute, 1}
	Inst{.eor, .index_absolute, 0}
	Inst{.lsr, .index_absolute, 0}
	// 0x6x
	Inst{.rts, .implied, 0}
	Inst{.adc, .xzero_page_indirect, 0}
	Inst{.adc, .zero_page, 0}
	Inst{.ror, .zero_page, 0}
	Inst{.pla, .implied, 0}
	Inst{.adc, .immediate, 0}
	Inst{.jmp, .indirect, 0}
	Inst{.eor, .absolute, 0}
	Inst{.lsr, .absolute, 0}
	// 0x7x
	Inst{.bvs, .absolute, 0}
]

struct Inst {
	a token.Kind
	b parse.AddressingMode
	c u8 // register
}

[direct_array_access]
pub fn gen(nodes []parse.Node) []u8 {
	mut s := []u8{}

	return s
}