CFLAGS += -g -static
CFLAGS += -Wall -Werror
LDFLAGS += -g -static

UNITS = kbd

all: $(patsubst %,tmp/%,$(UNITS))
	@for name in $(UNITS); do echo ./tmp/$$name && ./tmp/$$name; done
clean:
	rm -rf tmp
.PHONY: all clean

tmp/%: tmp/%.o
	@mkdir -p tmp
	$(CC) $(LDFLAGS) -o $@ $^

tmp/%.o: %.c common.h
	@mkdir -p tmp
	$(CC) $(CFLAGS) -c -o $@ $<
