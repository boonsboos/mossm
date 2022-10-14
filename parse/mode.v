module parse

pub enum AddressingMode {
	immediate
	absolute
	xabsolute
	yabsolute
	zero_page
	xzero_page
	xzero_page_indirect
	yindirect_zero_page
}