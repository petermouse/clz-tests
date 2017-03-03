CC ?= gcc
CFLAGS_common ?= -Wall -std=gnu99 -g -DDEBUG 
CFLAGS_iteration = -O0
CFLAGS_binary  = -O0
CFLAGS_byte  = -O0
CFLAGS_harley  = -O0
CFLAGS_recursive  = -O0
CFLAGS_overload  = -Wall -std=c++11 -g -DDEBUG -O0
ifeq ($(strip $(PROFILE)),1)
CFLAGS_common += -Dcorrect
endif
ifeq ($(strip $(CTZ)),1)
CFLAGS_harley += -DCTZ
endif
ifeq ($(strip $(MP)),1)
CFLAGS_common += -fopenmp -DMP
endif
EXEC = iteration binary byte recursive harley 

BEGIN ?= 67100000
END ?= 67116384

GIT_HOOKS := .git/hooks/pre-commit
.PHONY: all
all: $(GIT_HOOKS) $(EXEC)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

SRCS_common = main.c

iteration: $(SRCS_common) clz.h
	$(CC) $(CFLAGS_common) $(CFLAGS_iteration) \
		-o $@ -Diteration $(SRCS_common) 

binary: $(SRCS_common) clz.h
	$(CC) $(CFLAGS_common) $(CFLAGS_binary) \
		-o $@ -Dbinary $(SRCS_common) 

byte: $(SRCS_common) clz.h
	$(CC) $(CFLAGS_common) $(CFLAGS_byte) \
		-o $@ -Dbyte $(SRCS_common) 

harley: $(SRCS_common) clz.h
	$(CC) $(CFLAGS_common) $(CFLAGS_harley) \
		-o $@ -Dharley $(SRCS_common) 

recursive: $(SRCS_common) clz.h
	$(CC) $(CFLAGS_common) $(CFLAGS_recursive) \
		-o $@ -Drecursive $(SRCS_common) 


run: $(EXEC)
	taskset -c 1 ./iteration $(BEGIN) $(END)
	taskset -c 1 ./binary $(BEGIN) $(END)
	taskset -c 1 ./byte $(BEGIN) $(END)
	taskset -c 1 ./recursive $(BEGIN) $(END)
	taskset -c 1 ./harley $(BEGIN) $(END)

plot: iteration.txt byte.txt binary.txt recursive.txt harley.txt
	gnuplot scripts/runtime.gp

.PHONY: clean
clean:
	$(RM) $(EXEC) *.o *.txt *.png
