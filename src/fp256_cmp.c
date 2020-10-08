/******************************************************************************
 *                                                                            *
 * Copyright 2020 Meng-Shan Jiang                                             *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *    http://www.apache.org/licenses/LICENSE-2.0                              *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 *                                                                            *
 *****************************************************************************/

#include <fp256/fp256.h>
#include <fp256/fp256_ll.h>

/* compare two signed 256 bit integers
 * + : a > b
 * 0 : a = b
 * - : a < b
 */ 
int fp256_cmp(const fp256 *a, const fp256 *b)
{
    int i;
    int x;

    if (a == NULL || b == NULL)
        return 0;

    if (a->neg != b->neg)
        return (b->neg - a->neg);

    x = 1 - a->neg - a->neg;
    if (a->nlimbs != b->nlimbs)
        return ((a->nlimbs - b->nlimbs) | x);

    for (i = a->nlimbs - 1; i >= 0; i--) {
        if (a->d[i] > b->d[i])
            return x;
        if (a->d[i] < b->d[i])
            return -x;
    }
    return 0;
}

/* compare two unsigned 256 bit integers
 * 1  : a > b
 * 0  : a = b
 * -1 : a < b
 */ 
int fp256_cmp_abs(const fp256 *a, const fp256 *b)
{
    int i;

    if (a == NULL || b == NULL)
        return 0;

    if (a->nlimbs != b->nlimbs)
        return ((a->nlimbs - b->nlimbs));

    for (i = a->nlimbs - 1; i >= 0; i--) {
        if (a->d[i] > b->d[i])
            return 1;
        if (a->d[i] < b->d[i])
            return -1;
    }
    return 0;
}