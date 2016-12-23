module Hacl.EC.AddAndDouble

open FStar.Mul
open FStar.HyperStack
open FStar.Buffer

open Hacl.Bignum.Constants
open Hacl.Bignum.Parameters
open Hacl.Spec.Bignum.Fsum
open Hacl.Spec.Bignum.Fdifference
open Hacl.Spec.Bignum.Fproduct
open Hacl.Spec.Bignum.Modulo
open Hacl.Spec.Bignum.Fmul
open Hacl.EC.Point


val bound_by: seqelem -> nat -> Type0
let bound_by s x =
  let _ = () in
  (forall (i:nat). {:pattern (v (Seq.index s i))} i < len ==> v (Seq.index s i) < x)


val smax: seqelem -> nat -> Type0
let smax s x =
  let _ = () in
  v (Seq.index s 0) < x /\ v (Seq.index s 1) < x /\ v (Seq.index s 2) < x
  /\ v (Seq.index s 3) < x /\ v (Seq.index s 4) < x


let red_52 s = smax s 52
let red_53 s = smax s 53
let red_55 s = smax s 55


#set-options "--z3rlimit 10 --initial_fuel 0 --max_fuel 0"

private val mul_shift_reduce_unrolled__:
  input:seqelem{shift_reduce_pre input} -> input2:seqelem{
    sum_scalar_multiplication_pre_ (Seq.create len wide_zero) input (Seq.index input2 0) len
    /\ (let output1 = sum_scalar_multiplication_spec (Seq.create len wide_zero) input (Seq.index input2 0) len in
       let input1 = shift_reduce_spec input in
       sum_scalar_multiplication_pre_ output1 input1 (Seq.index input2 1) len
       /\ shift_reduce_pre input1
       /\ (let output2 = sum_scalar_multiplication_spec output1 input1 (Seq.index input2 1) len in
          let input2' = shift_reduce_spec input1 in
          sum_scalar_multiplication_pre_ output2 input2' (Seq.index input2 2) len
          /\ shift_reduce_pre input2'
          /\ (let output3 = sum_scalar_multiplication_spec output2 input2' (Seq.index input2 2) len in
             let input3 = shift_reduce_spec input2' in
             sum_scalar_multiplication_pre_ output3 input3 (Seq.index input2 3) len
             /\ shift_reduce_pre input3
             /\ (let output4 = sum_scalar_multiplication_spec output3 input3 (Seq.index input2 3) len in
                let input4 = shift_reduce_spec input3 in
                sum_scalar_multiplication_pre_ output4 input4 (Seq.index input2 4) len
                /\ shift_reduce_pre input4))))} ->
  Tot (s:seqelem_wide)
private let mul_shift_reduce_unrolled__ input input2 =
  let input_init = input in
  let output = Seq.create len wide_zero in
  let output1   = sum_scalar_multiplication_spec output input (Seq.index input2 0) len in
  let input1    = shift_reduce_spec input in
  let output2   = sum_scalar_multiplication_spec output1 input1 (Seq.index input2 1) len in
  let input2'   = shift_reduce_spec input1 in
  let output3   = sum_scalar_multiplication_spec output2 input2' (Seq.index input2 2) len in
  let input3    = shift_reduce_spec input2' in
  let output4   = sum_scalar_multiplication_spec output3 input3 (Seq.index input2 3) len in
  let input4    = shift_reduce_spec input3 in
  sum_scalar_multiplication_spec output4 input4 (Seq.index input2 4) len

inline_for_extraction let p53 : pos = pow2 53
inline_for_extraction let p55 : pos = pow2 55
inline_for_extraction let p108 : pos = pow2 108

let bounds (s:seqelem) (s0:nat) (s1:nat) (s2:nat) (s3:nat) (s4:nat) : GTot Type0 =
  v (Seq.index s 0) < s0 /\ v (Seq.index s 1) < s1 /\ v (Seq.index s 2) < s2
  /\ v (Seq.index s 3) < s3 /\ v (Seq.index s 4) < s4

let bounds' (s:seqelem_wide) (s0:nat) (s1:nat) (s2:nat) (s3:nat) (s4:nat) : GTot Type0 =
  w (Seq.index s 0) < s0 /\ w (Seq.index s 1) < s1 /\ w (Seq.index s 2) < s2
  /\ w (Seq.index s 3) < s3 /\ w (Seq.index s 4) < s4


#set-options "--z3rlimit 10 --initial_fuel 0 --max_fuel 0"

private let sum_scalar_multiplication_pre_' (sw:seqelem_wide) (s:seqelem) (scalar:limb) =
  w (Seq.index sw 0) + (v (Seq.index s 0) * v scalar) < pow2 wide_n
  /\ w (Seq.index sw 1) + (v (Seq.index s 1) * v scalar) < pow2 wide_n
  /\ w (Seq.index sw 2) + (v (Seq.index s 2) * v scalar) < pow2 wide_n
  /\ w (Seq.index sw 3) + (v (Seq.index s 3) * v scalar) < pow2 wide_n
  /\ w (Seq.index sw 4) + (v (Seq.index s 4) * v scalar) < pow2 wide_n


val lemma_sum_scalar_muitiplication_pre_:
  sw:seqelem_wide -> s:seqelem -> scalar:limb ->
  Lemma (sum_scalar_multiplication_pre_ sw s scalar len <==> 
    (sum_scalar_multiplication_pre_' sw s scalar))
let lemma_sum_scalar_muitiplication_pre_ sw s scalar = ()


val lemma_mul_ineq: a:nat -> b:nat -> c:nat -> d:nat -> Lemma
  (requires (a < c /\ b < d))
  (ensures (a * b < c * d))
let lemma_mul_ineq a b c d = ()

#set-options "--z3rlimit 100 --initial_fuel 0 --max_fuel 0"


val lemma_shift_reduce_spec_: s:seqelem{shift_reduce_pre s} -> Lemma
  (let s' = shift_reduce_spec s in
    v (Seq.index s' 0) = 19 * v (Seq.index s 4)
    /\ v (Seq.index s' 1) = v (Seq.index s 0)
    /\ v (Seq.index s' 2) = v (Seq.index s 1)
    /\ v (Seq.index s' 3) = v (Seq.index s 2)
    /\ v (Seq.index s' 4) = v (Seq.index s 3) )
let lemma_shift_reduce_spec_ s = ()


val lemma_sum_scalar_muitiplication_spec_: sw:seqelem_wide -> s:seqelem -> sc:limb ->
  Lemma (requires (sum_scalar_multiplication_pre_ sw s sc len))
        (ensures (sum_scalar_multiplication_pre_ sw s sc len
          /\ (let sw' = sum_scalar_multiplication_spec sw s sc len in
             w (Seq.index sw' 0) = w (Seq.index sw 0) + (v (Seq.index s 0) * v sc)
             /\ w (Seq.index sw' 1) = w (Seq.index sw 1) + (v (Seq.index s 1) * v sc)
             /\ w (Seq.index sw' 2) = w (Seq.index sw 2) + (v (Seq.index s 2) * v sc)
             /\ w (Seq.index sw' 3) = w (Seq.index sw 3) + (v (Seq.index s 3) * v sc)
             /\ w (Seq.index sw' 4) = w (Seq.index sw 4) + (v (Seq.index s 4) * v sc))))
let lemma_sum_scalar_muitiplication_spec_ sw s sc = ()


val lemma_shift_reduce_then_carry_wide_0:
  s1:seqelem{red_53 s1} ->
  s2:seqelem{red_55 s2} ->
  Lemma (sum_scalar_multiplication_pre_ (Seq.create len wide_zero) s1 (Seq.index s2 0) len
    /\ shift_reduce_pre s1
    /\ bounds (shift_reduce_spec s1) (19 * p53) p53 p53 p53 p53
    /\ bounds' (sum_scalar_multiplication_spec (Seq.create len wide_zero) s1 (Seq.index s2 0) len)
              p108 p108 p108 p108 p108)
let lemma_shift_reduce_then_carry_wide_0 s1 s2 =
  assert_norm (pow2 53 = 0x20000000000000);
  assert_norm (pow2 55 = 0x80000000000000);
  assert_norm (pow2 wide_n = 0x100000000000000000000000000000000);
  let bla = Seq.create len wide_zero in
  cut (w (Seq.index bla 0) = 0); cut (w (Seq.index bla 1) = 0); cut (w (Seq.index bla 2) = 0);
  cut (w (Seq.index bla 3) = 0); cut (w (Seq.index bla 4) = 0);
  cut (v (Seq.index s1 0) < 0x20000000000000); cut (v (Seq.index s1 1) < 0x20000000000000);
  cut (v (Seq.index s1 2) < 0x20000000000000); cut (v (Seq.index s1 3) < 0x20000000000000);
  cut (v (Seq.index s1 4) < 0x20000000000000);
  cut (v (Seq.index s2 0) < 0x80000000000000);
  lemma_mul_ineq (v (Seq.index s1 0)) (v (Seq.index s2 0)) 0x20000000000000 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 1)) (v (Seq.index s2 0)) 0x20000000000000 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 2)) (v (Seq.index s2 0)) 0x20000000000000 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 3)) (v (Seq.index s2 0)) 0x20000000000000 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 4)) (v (Seq.index s2 0)) 0x20000000000000 0x80000000000000;
  assert_norm(p108 = 0x20000000000000 * 0x80000000000000);
  cut (sum_scalar_multiplication_pre_' bla s1 (Seq.index s2 0));
  lemma_sum_scalar_muitiplication_pre_ bla s1 (Seq.index s2 0);
  lemma_shift_reduce_spec_ s1;
  let s1' = shift_reduce_spec s1 in
  Math.Lemmas.pow2_plus 53 55


val lemma_shift_reduce_then_carry_wide_1:
  o:seqelem_wide{bounds' o p108 p108 p108 p108 p108} ->
  s1:seqelem{bounds s1 (19*p53) p53 p53 p53 p53} ->
  s2:seqelem{red_55 s2} ->
  Lemma (sum_scalar_multiplication_pre_ o s1 (Seq.index s2 1) len
    /\ shift_reduce_pre s1
    /\ bounds (shift_reduce_spec s1) (19 * p53) (19*p53) p53 p53 p53
    /\ bounds' (sum_scalar_multiplication_spec o s1 (Seq.index s2 1) len)
              (20 * p108) (2*p108) (2*p108) (2*p108) (2*p108))
let lemma_shift_reduce_then_carry_wide_1 o s1 s2 =
  assert_norm (pow2 53 = 0x20000000000000);
  assert_norm (pow2 55 = 0x80000000000000);
  assert_norm (pow2 64 = 0x10000000000000000);
  assert_norm (pow2 wide_n = 0x100000000000000000000000000000000);
  lemma_mul_ineq (v (Seq.index s1 0)) (v (Seq.index s2 1)) (19 * p53) 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 1)) (v (Seq.index s2 1)) 0x20000000000000 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 2)) (v (Seq.index s2 1)) 0x20000000000000 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 3)) (v (Seq.index s2 1)) 0x20000000000000 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 4)) (v (Seq.index s2 1)) 0x20000000000000 0x80000000000000;
  assert_norm(p108 = 0x20000000000000 * 0x80000000000000);
  cut (sum_scalar_multiplication_pre_' o s1 (Seq.index s2 1));
  lemma_sum_scalar_muitiplication_pre_ o s1 (Seq.index s2 1);
  lemma_shift_reduce_spec_ s1;
  let s1' = shift_reduce_spec s1 in
  Math.Lemmas.pow2_plus 53 55


val lemma_shift_reduce_then_carry_wide_2:
  o:seqelem_wide{bounds' o (20 * p108) (2*p108) (2*p108) (2*p108) (2*p108)} ->
  s1:seqelem{bounds s1 (19*p53) (19*p53) p53 p53 p53} ->
  s2:seqelem{red_55 s2} ->
  Lemma (sum_scalar_multiplication_pre_ o s1 (Seq.index s2 2) len
    /\ shift_reduce_pre s1
    /\ bounds (shift_reduce_spec s1) (19 * p53) (19*p53) (19*p53) p53 p53
    /\ bounds' (sum_scalar_multiplication_spec o s1 (Seq.index s2 2) len)
              (39 * p108) (21*p108) (3*p108) (3*p108) (3*p108))
let lemma_shift_reduce_then_carry_wide_2 o s1 s2 =
  assert_norm (pow2 53 = 0x20000000000000);
  assert_norm (pow2 55 = 0x80000000000000);
  assert_norm (pow2 64 = 0x10000000000000000);
  assert_norm (pow2 wide_n = 0x100000000000000000000000000000000);
  lemma_mul_ineq (v (Seq.index s1 0)) (v (Seq.index s2 2)) (19 * p53) 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 1)) (v (Seq.index s2 2)) (19 * p53) 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 2)) (v (Seq.index s2 2)) 0x20000000000000 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 3)) (v (Seq.index s2 2)) 0x20000000000000 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 4)) (v (Seq.index s2 2)) 0x20000000000000 0x80000000000000;
  assert_norm(p108 = 0x20000000000000 * 0x80000000000000);
  cut (sum_scalar_multiplication_pre_' o s1 (Seq.index s2 2));
  lemma_sum_scalar_muitiplication_pre_ o s1 (Seq.index s2 2);
  lemma_shift_reduce_spec_ s1;
  let s1' = shift_reduce_spec s1 in
  Math.Lemmas.pow2_plus 53 55


val lemma_shift_reduce_then_carry_wide_3:
  o:seqelem_wide{bounds' o (39* p108) (21*p108) (3*p108) (3*p108) (3*p108)} ->
  s1:seqelem{bounds s1 (19*p53) (19*p53) (19*p53) p53 p53} ->
  s2:seqelem{red_55 s2} ->
  Lemma (sum_scalar_multiplication_pre_ o s1 (Seq.index s2 3) len
    /\ shift_reduce_pre s1
    /\ bounds (shift_reduce_spec s1) (19*p53) (19*p53) (19*p53) (19*p53) p53
    /\ bounds' (sum_scalar_multiplication_spec o s1 (Seq.index s2 3) len)
              (58 * p108) (40*p108) (22*p108) (4*p108) (4*p108))
let lemma_shift_reduce_then_carry_wide_3 o s1 s2 =
  assert_norm (pow2 53 = 0x20000000000000);
  assert_norm (pow2 55 = 0x80000000000000);
  assert_norm (pow2 64 = 0x10000000000000000);
  assert_norm (pow2 wide_n = 0x100000000000000000000000000000000);
  lemma_mul_ineq (v (Seq.index s1 0)) (v (Seq.index s2 3)) (19 * p53) 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 1)) (v (Seq.index s2 3)) (19 * p53) 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 2)) (v (Seq.index s2 3)) (19 * p53) 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 3)) (v (Seq.index s2 3)) 0x20000000000000 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 4)) (v (Seq.index s2 3)) 0x20000000000000 0x80000000000000;
  assert_norm(p108 = 0x20000000000000 * 0x80000000000000);
  cut (sum_scalar_multiplication_pre_' o s1 (Seq.index s2 3));
  lemma_sum_scalar_muitiplication_pre_ o s1 (Seq.index s2 3);
  lemma_shift_reduce_spec_ s1;
  let s1' = shift_reduce_spec s1 in
  Math.Lemmas.pow2_plus 53 55


val lemma_shift_reduce_then_carry_wide_4:
  o:seqelem_wide{bounds' o (58* p108) (40*p108) (22*p108) (4*p108) (4*p108)} ->
  s1:seqelem{bounds s1 (19*p53) (19*p53) (19*p53) (19*p53) p53} ->
  s2:seqelem{red_55 s2} ->
  Lemma (sum_scalar_multiplication_pre_ o s1 (Seq.index s2 4) len
    /\ shift_reduce_pre s1
    /\ bounds (shift_reduce_spec s1) (19*p53) (19*p53) (19*p53) (19*p53) (19*p53)
    /\ bounds' (sum_scalar_multiplication_spec o s1 (Seq.index s2 4) len)
              (77 * p108) (59*p108) (41*p108) (23*p108) (5*p108))
let lemma_shift_reduce_then_carry_wide_4 o s1 s2 =
  assert_norm (pow2 53 = 0x20000000000000);
  assert_norm (pow2 55 = 0x80000000000000);
  assert_norm (pow2 64 = 0x10000000000000000);
  assert_norm (pow2 wide_n = 0x100000000000000000000000000000000);
  lemma_mul_ineq (v (Seq.index s1 0)) (v (Seq.index s2 4)) (19 * p53) 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 1)) (v (Seq.index s2 4)) (19 * p53) 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 2)) (v (Seq.index s2 4)) (19 * p53) 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 3)) (v (Seq.index s2 4)) (19 * p53) 0x80000000000000;
  lemma_mul_ineq (v (Seq.index s1 4)) (v (Seq.index s2 4)) 0x20000000000000 0x80000000000000;
  assert_norm(p108 = 0x20000000000000 * 0x80000000000000);
  cut (sum_scalar_multiplication_pre_' o s1 (Seq.index s2 4));
  lemma_sum_scalar_muitiplication_pre_ o s1 (Seq.index s2 4);
  lemma_shift_reduce_spec_ s1;
  let s1' = shift_reduce_spec s1 in
  Math.Lemmas.pow2_plus 53 55
  

private val mul_shift_reduce_unrolled_0:
  output:seqelem_wide ->
  input_init:seqelem ->
  input:seqelem ->
  input2:seqelem{mul_shift_reduce_pre output input_init input input2 1} ->
  Tot (s:seqelem_wide{s == mul_shift_reduce_spec_ output input_init input input2 1})
private let mul_shift_reduce_unrolled_0 output input_init input input2 =
  let output1   = sum_scalar_multiplication_spec output input (Seq.index input2 4) len in
  output1


#set-options "--z3rlimit 10 --initial_fuel 2 --max_fuel 2"

private val mul_shift_reduce_unrolled_1:
  output:seqelem_wide ->
  input_init:seqelem ->
  input:seqelem ->
  input2:seqelem{mul_shift_reduce_pre output input_init input input2 2} ->
  Tot (s:seqelem_wide{s == mul_shift_reduce_spec_ output input_init input input2 2})
private let mul_shift_reduce_unrolled_1 output input_init input input2 =
  let output1   = sum_scalar_multiplication_spec output input (Seq.index input2 3) len in
  lemma_sum_scalar_multiplication_ output input (Seq.index input2 3) len;
  let input1    = shift_reduce_spec input in
  lemma_shift_reduce_spec input;
  lemma_mul_shift_reduce_spec_1 output1 output input_init input input1 input2 (v (Seq.index input2 3)) 2;
  mul_shift_reduce_unrolled_0 output1 input_init input1 input2


#set-options "--z3rlimit 10 --initial_fuel 2 --max_fuel 2"

private val mul_shift_reduce_unrolled_2:
  output:seqelem_wide ->
  input_init:seqelem ->
  input:seqelem ->
  input2:seqelem{mul_shift_reduce_pre output input_init input input2 3} ->
  Tot (s:seqelem_wide{s == mul_shift_reduce_spec_ output input_init input input2 3})
private let mul_shift_reduce_unrolled_2 output input_init input input2 =
  let output1   = sum_scalar_multiplication_spec output input (Seq.index input2 2) len in
  lemma_sum_scalar_multiplication_ output input (Seq.index input2 2) len;
  let input1    = shift_reduce_spec input in
  lemma_shift_reduce_spec input;
  lemma_mul_shift_reduce_spec_1 output1 output input_init input input1 input2 (v (Seq.index input2 2)) 3;
  mul_shift_reduce_unrolled_1 output1 input_init input1 input2


#set-options "--z3rlimit 10 --initial_fuel 2 --max_fuel 2"

private val mul_shift_reduce_unrolled_3:
  output:seqelem_wide ->
  input_init:seqelem ->
  input:seqelem ->
  input2:seqelem{mul_shift_reduce_pre output input_init input input2 4} ->
  Tot (s:seqelem_wide{s == mul_shift_reduce_spec_ output input_init input input2 4})
private let mul_shift_reduce_unrolled_3 output input_init input input2 =
  let output1   = sum_scalar_multiplication_spec output input (Seq.index input2 1) len in
  lemma_sum_scalar_multiplication_ output input (Seq.index input2 1) len;
  let input1    = shift_reduce_spec input in
  lemma_shift_reduce_spec input;
  lemma_mul_shift_reduce_spec_1 output1 output input_init input input1 input2 (v (Seq.index input2 1)) 4;
  mul_shift_reduce_unrolled_2 output1 input_init input1 input2


#set-options "--z3rlimit 10 --initial_fuel 2 --max_fuel 2"

private val mul_shift_reduce_unrolled_:
  output:seqelem_wide ->
  input_init:seqelem ->
  input:seqelem ->
  input2:seqelem{mul_shift_reduce_pre output input_init input input2 5} ->
  Tot (s:seqelem_wide{s == mul_shift_reduce_spec_ output input_init input input2 5})
private let mul_shift_reduce_unrolled_ output input_init input input2 =
  let output1   = sum_scalar_multiplication_spec output input (Seq.index input2 0) len in
  lemma_sum_scalar_multiplication_ output input (Seq.index input2 0) len;
  let input1    = shift_reduce_spec input in
  lemma_shift_reduce_spec input;
  lemma_mul_shift_reduce_spec_1 output1 output input_init input input1 input2 (v (Seq.index input2 0)) 5;
  mul_shift_reduce_unrolled_3 output1 input_init input1 input2


private val shift_reduce_unrolled:
  input:seqelem ->
  input2:seqelem{mul_shift_reduce_pre (Seq.create len wide_zero) input input input2 len} ->
  Tot (s:seqelem_wide{s == mul_shift_reduce_spec input input2})
private let shift_reduce_unrolled input input2 =
  mul_shift_reduce_unrolled_ (Seq.create len wide_zero) input input input2


#set-options "--z3rlimit 20 --initial_fuel 0 --max_fuel 0"

private val carry_wide_spec_unrolled:
  s:seqelem_wide{carry_wide_pre s 0} ->
  Tot (s':seqelem_wide{w (Seq.index s' 4) < w (Seq.index s 4) + pow2 (2*word_size-limb_size)})
private let carry_wide_spec_unrolled s =
  let s1 = carry_wide_step s 0 in
  lemma_carry_wide_step s 0;
  let s2 = carry_wide_step s1 1 in
  lemma_carry_wide_step s1 1;
  let s3 = carry_wide_step s2 2 in
  lemma_carry_wide_step s2 2;
  let s4 = carry_wide_step s3 3 in
  lemma_carry_wide_step s3 3;
  Math.Lemmas.lemma_div_lt (w (Seq.index s3 3)) (2*word_size) limb_size;
  cut (w (Seq.index s4 4) < w (Seq.index s 4) + pow2 (2*word_size - limb_size));
  s4


#set-options "--z3rlimit 20 --initial_fuel 5 --max_fuel 5"

private val lemma_carry_wide_spec_unrolled:
  s:seqelem_wide{carry_wide_pre s 0} -> Lemma (carry_wide_spec_unrolled s == carry_wide_spec s 0)
let lemma_carry_wide_spec_unrolled s = ()


#set-options "--z3rlimit 20 --initial_fuel 0 --max_fuel 0"

val lemma_copy_then_carry: s:seqelem_wide -> Lemma
  ((copy_from_wide_pre s /\ (w (Seq.index s 0) < pow2 word_size /\ w (Seq.index s 1) < pow2 limb_size
    /\ w (Seq.index s 2) < pow2 limb_size /\ w (Seq.index s 3) < pow2 limb_size
    /\ w (Seq.index s 4) < pow2 limb_size)) ==>
     (carry_0_to_1_pre (copy_from_wide_spec s) ))
let lemma_copy_then_carry s = ()



val lemma_carry_top_wide_then_copy: s:seqelem_wide{carry_top_wide_pre s} -> Lemma
  ((w (Seq.index s 0) + 19 * w (Seq.index s 4) / pow2 limb_size < pow2 word_size /\ w (Seq.index s 1) < pow2 word_size /\ w (Seq.index s 2) < pow2 word_size /\ w (Seq.index s 3) < pow2 word_size) ==> copy_from_wide_pre (carry_top_wide_spec s))
let lemma_carry_top_wide_then_copy s =
  lemma_carry_top_wide_spec_ s;
  assert_norm(pow2 64 > pow2 51)

#set-options "--z3rlimit 50 --initial_fuel 0 --max_fuel 0"

val lemma_carry_wide_then_carry_top: s:seqelem_wide{carry_wide_pre s 0} -> Lemma
  (((w (Seq.index s 4) + pow2 (2*word_size - limb_size))/ pow2 limb_size < pow2 word_size
    /\ 19 * (w (Seq.index s 4) + pow2 (2*word_size - limb_size) / pow2 limb_size) + pow2 limb_size < pow2 word_size)
    ==> carry_top_wide_pre (carry_wide_spec s 0) )
let lemma_carry_wide_then_carry_top s =
  let s' = carry_wide_spec_unrolled s in
  lemma_carry_wide_spec_unrolled s;
  cut (w (Seq.index s' 4) < w (Seq.index s 4) + pow2 (2*word_size-limb_size));
  Math.Lemmas.nat_times_nat_is_nat 19 (w (Seq.index s 4) + pow2 (2*word_size-limb_size));
  if ((w (Seq.index s 4) + pow2 (2*word_size - limb_size))/ pow2 limb_size < pow2 word_size
    && 19 * (w (Seq.index s 4) + pow2 (2*word_size - limb_size) / pow2 limb_size) + pow2 limb_size < pow2 word_size) then (
    Math.Lemmas.lemma_div_le (w (Seq.index s' 4)) (w (Seq.index s 4) + pow2 (2*word_size-limb_size)) (pow2 limb_size);
    cut (w (Seq.index s' 4) / pow2 limb_size <= (w (Seq.index s 4) + pow2 (2*word_size-limb_size)) / pow2 limb_size);
    Math.Lemmas.nat_over_pos_is_nat (w (Seq.index s' 4)) (pow2 limb_size);
    Math.Lemmas.nat_over_pos_is_nat (((w (Seq.index s 4)+(pow2 (2*word_size-limb_size)))/pow2 limb_size)) (pow2 limb_size);
    Math.Lemmas.multiplication_order_lemma (w (Seq.index s' 4) / pow2 limb_size)
                                           ((w (Seq.index s 4)+(pow2 (2*word_size-limb_size)))/pow2 limb_size) 19;
    cut (19 * (w (Seq.index s' 4) / pow2 limb_size) <= 19 * ((w (Seq.index s 4) + pow2 (2*word_size-limb_size)) / pow2 limb_size));
    cut (w (Seq.index s' 0) < pow2 limb_size);
    cut (19 * (w (Seq.index s' 4) / pow2 limb_size) + w (Seq.index s' 0) < pow2 word_size);
    Math.Lemmas.pow2_lt_compat (2*word_size) word_size
  )
  else ()


(* val lemma_shift_reduce_then_carry_wide_0: *)
(*   max1:nat -> s1:seqelem{smax s1 max1} -> *)
(*   max2:nat -> s2:seqelem{smax s2 max2} -> *)
(*   output:seqelem_wide -> *)
(*   Lemma (( *)