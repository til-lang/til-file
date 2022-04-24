dist/libtil_file.so: til source/app.d
	ldc2 --shared source/app.d \
		-I=til/source \
		-link-defaultlib-shared \
		-L-L${PWD}/dist -L-L${PWD}/til/dist -L-ltil \
		--O2 -of=dist/libtil_file.so

test:
	TIL_PATH="$$PWD/dist" til run test.til

debug:
	TIL_PATH="$$PWD/dist" til debug test.til

til:
	git clone https://github.com/til-lang/til.git til

clean:
	-rm dist/*.so
