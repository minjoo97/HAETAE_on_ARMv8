CC =gcc
CFLAGS += -Wall -Wextra -Wpedantic -Wmissing-prototypes -Wredundant-decls \
  -Wshadow -Wpointer-arith -O2 -fomit-frame-pointer -I../../../common -I./
NISTFLAGS += -Wno-unused-result -O2 -fomit-frame-pointer -I../../../common -I./
RM = /bin/rm

COMMON_DIR=../../../common
COMMON_FILES= $(COMMON_DIR)/randombytes.c  $(COMMON_DIR)/cpucycles.c $(COMMON_DIR)/fips202.c
COMMON_HEADERS= $(COMMON_DIR)/randombytes.h  $(COMMON_DIR)/cpucycles.h $(COMMON_DIR)/fips202.h

BENCH_DIR=../../sign_bench
BENCH_FILES=$(BENCH_DIR)/Sign_KPQC_bench.c
GENKAT_FILES= $(BENCH_DIR)/PQCgenKAT_sign.c

SOURCES= decompose.c encoding.c fft.c fixpoint.c ntt.c packing.c poly.c polyfix.c polymat.c polyvec.c reduce.c sampler.c sign.c symmetric-shake.c \
		mont_vec.s ntt_vec.s poly_pp_mont_vec.s polyadd_vec.s polysub_vec.s polyveck_frommont_vec.s inv_ntt_vec.s
HEADERS=  decompose.h encoding.h fft.h fixpoint.h ntt.h packing.h poly.h polyfix.h polymat.h polyvec.h reduce.h sampler.h sign.h symmetric.h rans_byte.h

GENKAT_SOURCES= $(COMMON_DIR)/aes.c $(COMMON_DIR)/sha2.c $(COMMON_DIR)/rng.c $(COMMON_DIR)/fips202.c
GENKAT_HEADERS= $(COMMON_DIR)/aes.h $(COMMON_DIR)/sha2.h $(COMMON_DIR)/rng.h $(COMMON_DIR)/fips202.h

.PHONY: all KpqC_bench PQCgenKAT clean

all: \
	KpqC_bench \
	PQCgenKAT

KpqC_bench: $(COMMON_HEADERS) $(HEADERS) $(COMMON_FILES) $(SOURCES) $(BENCH_FILES)
	$(CC) $(CFLAGS) -o $@ $(BENCH_FILES) $(SOURCES) $(COMMON_FILES) 

PQCgenKAT: $(GENKAT_HEADERS) $(HEADERS) $(GENKAT_SOURCES) $(SOURCES) $(GENKAT_FILES)
	$(CC) $(NISTFLAGS) -o $@ $(GENKAT_FILES) $(SOURCES) $(GENKAT_SOURCES)
 
clean:
	-$(RM) -f KpqC_bench
	-$(RM) -f PQCgenKAT
	rm -f *.rsp
	rm -f *.req
