PASCAL_COMPILER= fpc
COMPILER_OPTIONS= -gv

PROGRAMS = dense2sparse\
	   sparse2dense\
	   matrix_generator\
	   multiplyer\
	   indexer\
	   index_draw

all: $(PROGRAMS)


%: %.pas
	$(PASCAL_COMPILER) $(COMPILER_OPTIONS) $^

clean:
	rm -f *.o *.ppu $(PROGRAMS)


