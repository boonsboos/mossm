module compiler

import os

import token
import parse
import check
import gen

pub fn compile_file(filename string) {

	file := os.read_file(filename) or {
		eprintln('failed to read file `$filename`')
		exit(1)
	}

	tokens := token.tokenize(file.replace('\r','') + '\n')
	nodes := parse.parse(tokens)
	check.check(nodes) // do some sort of typechecking
	binary := gen.gen(nodes)
	
	mut out := os.create(filename.all_before_last('.')+'.6502') or {
		eprintln('failed to create output file')
		exit(1)
	}

	out.write(binary) or {
		eprintln('failed to write to output file')
		exit(1)
	}

	out.close()
}