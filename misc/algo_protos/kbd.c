#include <assert.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "common.h"

u8 kbd_state[16];

u8 get_ascii(void);
u8 get_keycode(bool reset);
u8 update_kbd_state(void);

int main(void) {
	// Test get_keycode.
	assert(get_keycode(false) == 0x90);
	assert(get_keycode(false) == 0xa6);
	for(int i = 0; i < 11; i++)
		get_keycode(false);
	assert(get_keycode(false) == 0x2c);
	assert(get_keycode(false) == 0xff);

	// Reset.
	assert(get_keycode(true) == 0x00);
	memset(kbd_state, 0, 16);

	// Test update_kbd_state.
	u16 state0[8] = {0x0000, 0x0000, 0x0000, 0x0000,
		             0x0000, 0x0000, 0x0000, 0x0000};
	u16 state1[8] = {0x0000, 0x0001, 0x0000, 0x0000,
		             0x0000, 0x0000, 0x0000, 0x0000};
	u16 state2[8] = {0x0000, 0x0001, 0x0040, 0x0000,
		             0x0000, 0x0000, 0x0000, 0x0000};
	u16 state3[8] = {0x0000, 0x0000, 0x0000, 0x0008,
		             0x0000, 0x0000, 0x0000, 0x0000};
	u16 state4[8] = {0x0000, 0x0000, 0x0200, 0x0000,
		             0x0000, 0x0000, 0x0000, 0x0000};
	u16 state5[8] = {0x0000, 0x0000, 0x0000, 0x0200,
		             0x0000, 0x0000, 0x0000, 0x0000};
	u16 state6[8] = {0x0000, 0x0000, 0x1000, 0x0000,
		             0x0000, 0x0000, 0x0000, 0x0000};
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state1, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state2, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state1, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state0, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state3, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state0, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state4, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state0, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state4, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state0, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state5, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state0, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state6, 16);
	assert(update_kbd_state() != 0);
	assert_memcmp(kbd_state, (u8*) state0, 16);
	assert(update_kbd_state() == 0xff);

	// Reset.
	assert(get_keycode(true) == 0x00);
	memset(kbd_state, 0, 16);

	// Test get_ascii.
	assert(get_ascii() == 'h');
	assert(get_ascii() == 'e');
	assert(get_ascii() == 'l');
	assert(get_ascii() == 'l');
	assert(get_ascii() == 'o');
	assert(get_ascii() == '\n');
	assert(get_ascii() == 0xff);
	assert(get_keycode(false) == 0xff);

	return 0;
}

u8 get_ascii(void) {
	const u8 TABLE[256] = {
		   0,   0,   0,   0, ' ',   0,   0,   0,   0,   0,   0,    0,    0,    0, 0, 0,
		   0, 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',    0,    0,    0, 0, 0,
		   0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', 0x0a,    0, 0, 0,
		0x09, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',  '[',  ']', '\\', 0, 0,
		 '`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',  '-',  '=', 0x08, 0, 0,
		   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  0x7f,    0, 0, 0,
		0x1b,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,     0,    0, 0, 0,
		   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,     0,    0, 0, 0,

		   0,   0,   0,   0, ' ',   0,   0,   0,   0,   0,   0,    0,    0,    0, 0, 0,
		   0, 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?',    0,    0,    0, 0, 0,
		   0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':',  '"', 0x0a,    0, 0, 0,
		0x09, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',  '{',  '}',  '|', 0, 0,
		 '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')',  '_',  '+', 0x08, 0, 0,
		   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  0x7f,    0, 0, 0,
		0x1b,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,     0,    0, 0, 0,
		   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,     0,    0, 0, 0,
	};

	do {
		u8 keycode = update_kbd_state();
		if(keycode == 0)
			continue;
		else if(keycode == 0xff)
			return 0xff;
		else if((keycode & 0x80) != 0)
			continue;

		keycode |= ((kbd_state[2] & 0x08) != 0 || (kbd_state[3] & 0x01) != 0) ? 0x80 : 0x00;

		u8 ascii = TABLE[keycode];
		if(ascii == 0)
			continue;
		else
			return ascii;
	} while(true);
}

u8 update_kbd_state(void) {
	u8 n = get_keycode(false);
	if(n == 0 || n == 0xff)
		return n;

	bool down = (n >> 7) != 0;
	u8 bit = n & 0x07;
	u8 byte = (n >> 3) & 0x0f;

	u8* ptr = &kbd_state[byte];
	if(down) {
		*ptr = *ptr | (1 << bit);
	} else {
		*ptr = *ptr & ~(1 << bit);
	}

	return n;
}

u8 get_keycode(bool reset) {
	static u8 keycodes[] = {0x90, 0xa6, 0x26, 0x10, 0xb3, 0x33, 0xa9, 0x29,
		0xa9, 0x29, 0xb9, 0x39, 0xac, 0x2c};
	static usize i = 0;

	if(reset) {
		i = 0;
		return 0;
	} else if(i < sizeof(keycodes)) {
		return keycodes[i++];
	} else {
		return 0xff;
	}
}
