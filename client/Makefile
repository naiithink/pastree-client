CC		:= clang
CFLAGS	:= ""
OUT		:= client

.PHONY:	all clean .FORCE

all: clean $(OUT)

%: %.c
	$(CC) $(CFLAGS) $< -o $@

clean:
	@rm -rf $(OUT)
