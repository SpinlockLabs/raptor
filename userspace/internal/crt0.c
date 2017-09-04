#include <liblox/lox-internal.h>

extern int main(int argc, char** argv);

void __output_string(char* s) {
    unused(s);
}

void __output_char(char c) {
    unused(c);
}

void __abort(char* msg) {
    unused(msg);
}

used void _start(void) {
    char* args[1] = {
            "exe"
    };
    main(0, args);
}

void (*lox_output_string_provider)(char*) = __output_string;
void (*lox_output_char_provider)(char) = __output_char;
void (*lox_abort_provider)(char*) = __abort;
