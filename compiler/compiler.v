module compiler

import os

import token

pub fn compile_file(filename string) {

	file := os.read_file(filename) or {
		eprintln('failed to read file `$filename`')
		exit(1)
	}

	tokens := token.tokenize(file.replace('\r','') + '\n')
	println(tokens)

}