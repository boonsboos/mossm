module check

import token
import parse

const (
	// the implied mode is already verified in the parsing step.
	accumulator = [token.Kind.asl, .lsr, .rol, .ror]
	
	absolute_indirect = [token.Kind.jmp]
	
	immediate = [token.Kind.adc, .and, .cmp, .cpx, .cpy, .eor, .lda, .ldx, .ldy, .ora, .sbc]
	// includes relative because they look the same
	absolute = [token.Kind.adc, .and, .asl, .bcc, .bcs, .beq, .bmi, .bne, .bpl, .bvc, .bvs, .bit, .cmp, .cpx, .cpy, .dec, .eor, .inc, .jmp, .jsr, .lda, .ldx, .ldy, .lsr, .ora, .rol, .ror, .sbc, .sta, .stx, .sty]
	
	xindex_absolute = [token.Kind.adc, .and, .asl, .cmp, .dec, .eor, .inc, .lda, .ldy, .lsr, .ora, .rol, .ror, .sbc, .sta]
	yindex_aboslute = [token.Kind.adc, .and, .cmp, .eor, .lda, .ldx, .ora, .sbc, .sta]
	
	zero_page = [token.Kind.adc, .and, .asl, .bit, .cmp, .cpx, .cpy, .dec, .eor, .inc, .lda, .ldx, .ldy, .lsr,. ora, .rol, .ror, .sbc, .sta, .stx, .sty]
	xindex_zero_page = [token.Kind.adc, .and, .asl, .cmp, .dec, .eor, .inc, .lda, .ldy, .lsr, .ora, .rol, .ror, .sbc, .sta, .sty]
	yindex_zero_page = [token.Kind.ldx, .stx]
	
	xzero_page_indirect = [token.Kind.adc, .and, .cmp, .eor, .lda, .ora, .sbc, .sta]
	yindirect_zero = [token.Kind.adc, .and, .cmp, .eor, .lda, .ora, .sbc, .sta]
)

pub fn check(nodes []parse.Node) {
	mut check_error := 0

	mut labels := []string{}

	for node in nodes {
		if node.node == .label {
			labels << node.label
		}

		if node.label !in labels && node.label != '' {
			eprintln('${node.row}:${node.col} the label that is referred to does not exist')
			check_error++
		}

		// another incomprehensible mess
		match node.mode {
			.accumulator {
				if node.inst !in accumulator {
					eprintln('${node.row}:${node.col} `$node.inst` does not support accumulator addressing')
					check_error++
				}
			}
			.absolute_indirect {
				if node.inst !in absolute_indirect {
					eprintln('${node.row}:${node.col} `$node.inst` does not support absolute indirect addressing')
					check_error++
				}
			}
			.absolute {
				if node.inst !in absolute {
					eprintln('${node.row}:${node.col} `$node.inst` does not support absolute addressing')
					check_error++
				}
			}
			.immediate {
				if node.inst !in immediate {
					eprintln('${node.row}:${node.col} `$node.inst` does not support immediate mode')
					check_error++
				}
			}
			.index_absolute {
				if node.register == 0 { // X
					if node.inst !in xindex_absolute {
						eprintln('${node.row}:${node.col} `$node.inst` does not support X-indexed absolute addressing')
						check_error++
					}
				} else { // Y
					if node.inst !in yindex_aboslute {
						eprintln('${node.row}:${node.col} `$node.inst` does not support Y-indexed absolute addressing')
						check_error++
					}
				}
			}
			.zero_page {
				if node.inst !in zero_page {
					eprintln('${node.row}:${node.col} `$node.inst` does not support zero page addressing')
					check_error++
				}
			}
			.index_zero_page {
				if node.register == 0 { // X
					if node.inst !in xindex_zero_page {
						eprintln('${node.row}:${node.col} `$node.inst` does not support X-indexed zero page addressing')
						check_error++
					}
				} else { // Y
					if node.inst !in yindex_zero_page {
						eprintln('${node.row}:${node.col} `$node.inst` does not support Y-indexed zero page addressing')
						check_error++
					}
				}
			}
			.xzero_page_indirect {
				if node.inst !in xzero_page_indirect {
					eprintln('${node.row}:${node.col} `$node.inst` does not support X-indexed indirect zero page addressing')
					check_error++
				}
			}
			.yindirect_zero_page {
				if node.inst !in yindirect_zero {
					eprintln('${node.row}:${node.col} `$node.inst` does not support Y-indexed indirect zero page addressing')
					check_error++
				}
			}
			else {}
		}
	}

	if check_error > 0 {
		exit(1)
	}
}