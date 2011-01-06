
GCC	:= gcc -std=c99

all: textureAtlas joinPlists

textureAtlas: TextureAtlasPacker.o main.o
	$(GCC) -framework Foundation -framework AppKit $^ -o $@

TextureAtlasPacker.o: TextureAtlasPacker.m TextureAtlasPacker.h
	$(GCC) -c $<

main.o: main.m
	$(GCC) -c $<

joinPlists: joinPlists.m
	$(GCC) -framework Foundation $^ -o $@

clean:
	rm -rf *.o *~

.PHONY: all clean
