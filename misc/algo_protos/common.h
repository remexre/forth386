#ifndef COMMON_H
#define COMMON_H 1

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
typedef size_t usize;

#define assert_memcmp(a, b, n)                                            \
	do {                                                                  \
		u8* __assert_memcmp_a = a;                                        \
		u8* __assert_memcmp_b = b;                                        \
		usize __assert_memcmp_n = n;                                      \
		usize __assert_memcmp_i = 0;                                      \
		usize __assert_memcmp_ok = true;                                  \
		while(__assert_memcmp_i < __assert_memcmp_n) {                    \
			u8 __assert_memcmp_l = __assert_memcmp_a[__assert_memcmp_i];  \
			u8 __assert_memcmp_r = __assert_memcmp_b[__assert_memcmp_i];  \
			if(__assert_memcmp_l != __assert_memcmp_r) {                  \
				fprintf(stderr, "0x%02x != 0x%02x at index %lu.\n",       \
					__assert_memcmp_l, __assert_memcmp_r,                 \
					__assert_memcmp_i);                                   \
				__assert_memcmp_ok = false;                               \
			}                                                             \
			__assert_memcmp_i++;                                          \
		}                                                                 \
		if(!__assert_memcmp_ok) {                                         \
			fprintf(stderr, "Assertion failure at line %d.\n", __LINE__); \
			abort();                                                      \
		}                                                                 \
	} while(0)

#endif
