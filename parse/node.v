module parse

import token

pub enum NodeType {
	instruction
	label
} 

pub struct Node {
pub:
	node     NodeType
	mode     AddressingMode
	inst     token.Kind
	operand  u16
	register u8 // 0 == X, 1 == Y
	label    string
	col int
	row int
}