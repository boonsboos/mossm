module parse

pub enum AddressingMode {
	no
	accumulator // only A
	immediate // #$nn
	implied // no operand
	absolute // $nnnn
	index_absolute // $nnnn,X|Y
	absolute_indirect // ($nnnn)
	zero_page // $nn
	index_zero_page // $nn,X|Y
	xzero_page_indirect // ($nn,X)
	yindirect_zero_page // ($nn),Y
}