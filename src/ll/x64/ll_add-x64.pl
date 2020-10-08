##############################################################################
#                                                                            #
# Copyright 2020 Meng-Shan Jiang                                             #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License");            #
# you may not use this file except in compliance with the License.           #
# You may obtain a copy of the License at                                    #
#                                                                            #
#    http://www.apache.org/licenses/LICENSE-2.0                              #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#                                                                            #
##############################################################################

$flavour = shift;
$output  = shift;

# if ($flavour =~ /\./) { $output = $flavour; undef $flavour; }

$win64=0; $win64=1 if ($flavour =~ /[nm]asm|mingw64/ || $output =~ /\.asm$/);

$0 =~ m/(.*[\/\\])[^\/\\]+$/; $dir=$1;
( $xlate="${dir}x86_64-xlate.pl" and -f $xlate ) or
( $xlate="${dir}../perlasm/x86_64-xlate.pl" and -f $xlate) or
die "can't locate x86_64-xlate.pl";

open OUT,"| \"$^X\" \"$xlate\" $flavour \"$output\"";
*STDOUT=*OUT;

$avx = 2;
$addx = 1;

$code.=<<___;
.text
___

{
my ($r_ptr,$a_ptr,$b_ptr,$l,$b)=("%rdi","%rsi","%rdx","%rcx","%rdx");
my ($borrow,$carry,$t1,$t2)=("%rax","%rax","%r9","%r10");
$code.=<<___;

# u64 ll_add_limb(u64 *rd, u64 *ad, u64 b, size_t al);
.globl	ll_add_limb
.type	ll_add_limb,\@function,4
.align	32
ll_add_limb:
    xor $carry, $carry
.ll_add_limb_loop:
    test $l, $l             # CF = 0
    jz .ll_add_limb_done
    mov 0($a_ptr), $t1
    # CF = carry
    test $carry, $carry
    jz .ll_add_limb_nocarry
    stc                     # CF = 1
.ll_add_limb_nocarry:
    lea 8($a_ptr), $a_ptr
    adc $b, $t1             # a + b
    setc %al                # carry = CF
    mov $t1, 0($r_ptr)
    xor $b, $b
    dec $l
    lea 8($r_ptr), $r_ptr
    jmp .ll_add_limb_loop

.ll_add_limb_done:
    ret
.size	ll_add_limb,.-ll_add_limb

# u64 ll_add_limbs(u64 *rd, u64 *ad, u64 *bd, size_t l);
.globl	ll_add_limbs
.type	ll_add_limbs,\@function,4
.align	32
ll_add_limbs:
    xor $carry, $carry
.ll_add_limbs_loop:
    test $l, $l             # CF = 0
    jz .ll_add_limbs_done
    mov 0($a_ptr), $t1
    mov 0($b_ptr), $t2
    # CF = carry
    test $carry, $carry
    jz .ll_add_limbs_nocarry
    stc                     # CF = 1
.ll_add_limbs_nocarry:
    lea 8($a_ptr), $a_ptr
    adc $t2, $t1            # a + b
    lea 8($b_ptr), $b_ptr
    setc %al                # carry = CF
    mov $t1, 0($r_ptr)
    dec $l
    lea 8($r_ptr), $r_ptr
    jmp .ll_add_limbs_loop

.ll_add_limbs_done:
    ret
.size	ll_add_limbs,.-ll_add_limbs

# u64 ll_sub_limb(u64 *rd, u64 *ad, u64 b, size_t al);
.globl	ll_sub_limb
.type	ll_sub_limb,\@function,4
.align	32
ll_sub_limb:
    xor $borrow, $borrow
.ll_sub_limb_loop:
    test $l, $l             # CF = 0
    jz .ll_sub_limb_done
    mov 0($a_ptr), $t1
    # CF = borrow
    test $borrow, $borrow
    jz .ll_sub_limb_noborrow
    stc                     # CF = 1
.ll_sub_limb_noborrow:
    lea 8($a_ptr), $a_ptr
    sbb $b, $t1             # a - b
    setc %al                # borrow = CF
    mov $t1, 0($r_ptr)
    xor $b, $b
    dec $l
    lea 8($r_ptr), $r_ptr
    jmp .ll_sub_limb_loop

.ll_sub_limb_done:
    ret
.size	ll_sub_limb,.-ll_sub_limb

# u64 ll_sub_limbs(u64 *rd, u64 *ad, u64 *bd, size_t l);
.globl	ll_sub_limbs
.type	ll_sub_limbs,\@function,4
.align	32
ll_sub_limbs:
    xor $borrow, $borrow
.ll_sub_limbs_loop:
    test $l, $l             # CF = 0
    jz .ll_sub_limbs_done
    mov 0($a_ptr), $t1
    mov 0($b_ptr), $t2
    # CF = borrow
    test $borrow, $borrow
    jz .ll_sub_limbs_noborrow
    stc                     # CF = 1
.ll_sub_limbs_noborrow:
    lea 8($a_ptr), $a_ptr
    sbb $t2, $t1            # a - b
    lea 8($b_ptr), $b_ptr
    setc %al                # borrow = CF
    mov $t1, 0($r_ptr)
    dec $l
    lea 8($r_ptr), $r_ptr
    jmp .ll_sub_limbs_loop

.ll_sub_limbs_done:
    ret
.size	ll_sub_limbs,.-ll_sub_limbs
___
}

$code =~ s/\`([^\`]*)\`/eval $1/gem;
print $code;
close STDOUT or die "error closing STDOUT: $!";