module parse

import encoding.hex // dum
import encoding.binary // dum²

import token

const (
	length_1 = [
		token.Kind.nop, .kil, .tax, .tay, .tsx, .txa, .tya, .txs,
		.brk, .pha, .php, .pla, .plp, .dec, .dex, .dey, .inc, .inx,
		.iny, .rti, .rts, .clc, .cld, .cli, .clv, .sec, .sed, .sei
	]
)

[direct_array_access]
pub fn parse(tokens []token.Token) []Node {
	mut nodes := []Node{}
	mut idx   := 0

	mut parse_error := 0

	for idx < tokens.len {

		//
		// PARSE INSTRUCTIONS
		//

		// for instructions of length 1 (only itself)
		if tokens[idx].inst in length_1 {
			nodes << Node{.instruction, .implied, tokens[idx].inst, 0, 0, '', tokens[idx].col, tokens[idx].row} // 0, 0 because no operands.
			idx++
			continue
		}

		// immediate mode
		if tokens[idx+1].inst == .hash {
			if tokens[idx+2].inst != .dollar {
				eprintln("${tokens[idx+2].row}:${tokens[idx+2].col} expected dollar sign, but found a `${tokens[idx+2].inst}` instead")
				parse_error++
			}
			if tokens[idx+3].inst != .literal {
				eprintln("${tokens[idx+3].row}:${tokens[idx+3].col} expected number, but found a ${tokens[idx+3].inst} instead")
				parse_error++
			}
			if tokens[idx+3].real.len > 2 {
				eprintln("${tokens[idx+3].row}:${tokens[idx+3].col} this instruction does not accept 16-bit numbers")
				parse_error++
			}

			nodes << Node{
				.instruction,
				.immediate,
				tokens[idx].inst,
				decode_hex_string(tokens[idx+3].real),
				0,
				'',
				tokens[idx].col,
				tokens[idx].row
			}
			idx += 4
			continue
		}

		// this has to be absolute or relative addressing.
		// but this time, with a label
		if tokens[idx+1].inst == .ident {
			nodes << Node{
				.instruction,
				.absolute,
				tokens[idx].inst,
				0,
				0,
				tokens[idx+1].real,
				tokens[idx].col,
				tokens[idx].row
			}
			idx += 2
			continue
		}

		// accumulator addressing
		if tokens[idx+1].inst == .a {
			nodes << Node{
				.instruction,
				.accumulator,
				tokens[idx].inst,
				0,
				0,
				'',
				tokens[idx].col,
				tokens[idx].row
			}
			idx += 2
			continue
		}

		// either absolute, indexed absolute or zero page
		if tokens[idx+1].inst == .dollar {
			if tokens[idx+2].inst != .literal {
				eprintln("${tokens[idx+2].row}:${tokens[idx+2].col} expected number, but found a ${tokens[idx+2].inst} instead")
				parse_error++
			}

			// zero page
			// $nn
			if tokens[idx+2].real.len < 4 {
				// X indexed zero page
				if tokens[idx+3].inst == .comma {
					if tokens[idx+4].inst !in [token.Kind.x, .y] {
						eprintln("${tokens[idx+3].row}:${tokens[idx+3].col} expected the either the X or Y register, but found a ${tokens[idx+3].inst} instead")
						parse_error++
					}
					
					register := if tokens[idx+4].inst == .x { u8(0) } else { 1 }
					nodes << Node{
						.instruction,
						.index_zero_page,
						tokens[idx].inst,
						decode_hex_string(tokens[idx+2].real),
						u8(register),
						'',
						tokens[idx].col,
						tokens[idx].row
					}
					idx += 5
					continue
				}

				// absolute zero page
				nodes << Node{
					.instruction,
					.zero_page,
					tokens[idx].inst,
					decode_hex_string(tokens[idx+3].real),
					0,
					'',
					tokens[idx].col,
					tokens[idx].row
				}
				idx += 3
				continue
			}

			// absolute
			// $nnnn
			if tokens[idx+3].inst != .comma {
				nodes << Node{
					.instruction,
					.absolute,
					tokens[idx].inst,
					decode_hex_string(tokens[idx+2].real),
					0,
					'',
					tokens[idx].col,
					tokens[idx].row
				}
				idx += 3
				continue
			}

			// check if there is actually a register
			if tokens[idx+4].inst !in [token.Kind.x, .y] {
				eprintln("${tokens[idx+3].row}:${tokens[idx+3].col} expected either the X or Y register, but found a ${tokens[idx+4].inst} instead")
				parse_error++
			}

			// indexed absolute
			register := if tokens[idx+4].inst == .x { u8(0) } else { 1 }
			nodes << Node{
				.instruction,
				.index_absolute,
				tokens[idx].inst,
				decode_hex_string(tokens[idx+3].real),
				register,
				'',
				tokens[idx].col,
				tokens[idx].row
			}
			idx += 5
			continue
		}

		// indirect
		if tokens[idx+1].inst == .paren_l {
			if tokens[idx+2].inst != .dollar {
				eprintln("${tokens[idx+2].row}:${tokens[idx+2].col} expected dollar sign, but found a `${tokens[idx+2].inst}` instead")
				parse_error++
			}
			if tokens[idx+3].inst != .literal {
				eprintln("${tokens[idx+3].row}:${tokens[idx+3].col} expected number, but found a `${tokens[idx+3].inst}` instead")
				parse_error++
			}

			// absolute indirect
			if tokens[idx+3].real.len == 4 {
				if tokens[idx+4].inst != .paren_r {
					eprintln("${tokens[idx+3].row}:${tokens[idx+3].col} please close the parentheses.")
					parse_error++
				}
				nodes << Node{
					.instruction,
					.absolute_indirect,
					tokens[idx].inst,
					decode_hex_string(tokens[idx+3].real),
					0,
					'',
					tokens[idx].col,
					tokens[idx].row
				}
				idx += 5
				continue
			}

			// x-indexed zero page indirect
			if tokens[idx+4].inst == .comma {
				if tokens[idx+5].inst != .x {
					eprintln("${tokens[idx+4].row+1}:${tokens[idx+4].col+1} expected the X register, but found `${tokens[idx+4].inst}` instead")
					parse_error++
				}
				if tokens[idx+6].inst != .paren_r {
					eprintln("${tokens[idx+5].row}:${tokens[idx+5].col} please close the parentheses.")
					parse_error++
				}

				nodes << Node{
					.instruction,
					.xzero_page_indirect,
					tokens[idx].inst,
					decode_hex_string(tokens[idx+3].real),
					0,
					'',
					tokens[idx].col,
					tokens[idx].row
				}
				idx += 7
				continue

			} else if tokens[idx+4].inst == .paren_r {
				if tokens[idx+5].inst != .comma {
					eprintln("${tokens[idx+4].row+1}:${tokens[idx+4].col+1} expected a comma, but found `${tokens[idx+4].inst}` instead")
					parse_error++
				}
				if tokens[idx+6].inst != .y {
					eprintln("${tokens[idx+5].row+1}:${tokens[idx+5].col+1} expected the X register, but found `${tokens[idx+5].inst}` instead")
					parse_error++
				}

				nodes << Node{
					.instruction,
					.xzero_page_indirect,
					tokens[idx].inst,
					decode_hex_string(tokens[idx+3].real),
					0,
					'',
					tokens[idx].col,
					tokens[idx].row
				}
				idx += 7
				continue
			}
		}

		//
		// PARSE LABELS
		//

		if tokens[idx].inst == .ident {
			if tokens[idx+1].inst != .colon {
				eprintln("${tokens[idx+1].row}:${tokens[idx+1].col} expected a colon (:), but found a `${tokens[idx+1].inst}` instead")
				parse_error++
			}

			nodes << Node {
				.label,
				.no,
				.ident,
				0,
				0,
				tokens[idx].real,
				tokens[idx].col,
				tokens[idx].row
			}

			idx += 2
			continue
		}
	
	} 

	if parse_error > 0 {
		exit(1)
	}

	return nodes
}

// the stupidest function you will ever see
[inline;direct_array_access]
fn decode_hex_string(a string) u16 {
	mut b := hex.decode(a) or { [u8(0x00), 0x00] }
	if b.len == 1 {
		b.prepend(u8(0x00))
	}
	return binary.big_endian_u16(b)
}