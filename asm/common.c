#include "common.h" 

void flag(char * msg, flags_e type) {

    if (type == ERROR) {
        printf("ERROR: %s!!\n",msg);
        exit(1);
    } 
    printf("WARNING: %s!\n",msg);
}
