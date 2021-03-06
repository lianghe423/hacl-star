(* NOTE: This is an interface module aimed at reducing the size of
   Ed25519 dependencies.  For the full detailed SHA2-512 specification
   refer to the Spec.SHA2_512 module *)
module Spec.SHA512

open FStar.Mul
open FStar.Seq
open FStar.UInt64

#reset-options "--max_fuel 0 --z3rlimit 20"

val k:     k:seq UInt64.t{length k = 80}
val h_0: h_0:seq UInt64.t{length h_0 = 8}

let size_k_w = 80

let bytes  = seq UInt8.t
let hash_w = m:seq UInt64.t {length m = 8}

val update: hash:hash_w -> block:bytes{length block = 128} -> Tot hash_w
val update_multi: hash:hash_w -> blocks:bytes{length blocks % 128 = 0} -> Tot hash_w (decreases (length blocks))
val update_last: hash:hash_w -> prevlen:nat{prevlen % 128 = 0} -> input:bytes{(Seq.length input) + prevlen < pow2 125} -> Tot hash_w
val finish: hashw:hash_w -> Tot (hash:bytes{length hash = 64})
val hash: s:seq UInt8.t{length s < pow2 125} -> Tot (s':seq UInt8.t{length s' = 64})
