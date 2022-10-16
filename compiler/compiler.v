module compiler

import os

import token
import parse
import check

pub fn compile_file(filename string) {

	file := os.read_file(filename) or {
		eprintln('failed to read file `$filename`')
		exit(1)
	}

	tokens := token.tokenize(file.replace('\r','') + '\n')
	nodes := parse.parse(tokens)
	check.check(nodes) // do some sort of typechecking
}