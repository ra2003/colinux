/*
 * This source code is a part of coLinux source package.
 *
 * Dan Aloni <da-x@gmx.net>, 2003-2004 (c)
 *
 * The code is licensed under the GPL. See the COPYING file at
 * the root directory.
 *
 */ 

#include <windows.h>

extern "C" {
	#include <colinux/common/debug.h>
}

#include <colinux/user/console/main.h>

static HHOOK current_hook;
static LRESULT CALLBACK keyboard_hook(      
    int nCode,
    WPARAM wParam,
    LPARAM lParam
)
{
	co_scan_code_t sc;
	sc.code = (lParam >> 16) & 0xff;
	sc.down = (lParam & (1 << 31)) ? 0 : 1;

	co_user_console_handle_scancode(sc);

	return CallNextHookEx(current_hook, nCode, wParam, lParam);
}

int main(int argc, char **argv) 
{
	current_hook = SetWindowsHookEx(WH_KEYBOARD,
					keyboard_hook,
					NULL,
					GetCurrentThreadId());

	return co_user_console_main(argc, argv);
}
