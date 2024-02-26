/*
 * Copyright 2020 ETH Zurich
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: Robert Balas <balasr@iis.ee.ethz.ch>
 */

#include <stdio.h>
#include <stdlib.h>
#include "csr.h"

int main(int argc, char *argv[])
{
    unsigned int cycles;
    unsigned int a;
    
    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    CSR_WRITE(CSR_REG_MCYCLE, 0);

    //test for performance counter
    a = 2+2;
    a = 3+18;
    a = 20+12;

    CSR_READ(CSR_REG_MCYCLE, &cycles);
    printf("%d cycles\n", cycles);
    /* write something to stdout */
    printf("hello world!\n");
    return EXIT_SUCCESS;
}

