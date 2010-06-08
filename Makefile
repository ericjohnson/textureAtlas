
GCC	:= gcc -std=c99

all: textureAtlas

textureAtlas: TextureAtlasPacker.o main.o
	$(GCC) -framework Foundation -framework AppKit $^ -o $@

TextureAtlasPacker.o: TextureAtlasPacker.m TextureAtlasPacker.h
	$(GCC) -c $<

main.o: main.m
	$(GCC) -c $<
