module main

import os
import compiler

fn main() {

	if os.args.len < 2 { exit(1) }

	compiler.compile_file(os.args[1])
}