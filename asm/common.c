#include "common.h" 

void flag(char * msg, flags_e type) {

    if (type == ERROR) {
        printf("#%d: ERROR: %s!!\n",line,msg);
        exit(1);
    } 
    printf("#%d: WARNING: %s!\n",line,msg);
    exit(1);
}
