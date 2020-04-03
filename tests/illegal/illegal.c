#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

#include "console.h"

#define TEST "Test "
#define PASS "PASS\r\n"
#define FAIL "FAIL\r\n"

extern int ill_test_1(void);

// i < 100
void print_test_number(int i)
{
	putstr(TEST, strlen(TEST));
	putchar(48 + i/10);
	putchar(48 + i%10);
	putstr(":", 1);
}

int main(void)
{
	int fail = 0;

	potato_uart_init();

	print_test_number(1);
	if (ill_test_1() != 0) {
		fail = 1;
		putstr(FAIL, strlen(FAIL));
	} else
		putstr(PASS, strlen(PASS));

	return fail;
}
