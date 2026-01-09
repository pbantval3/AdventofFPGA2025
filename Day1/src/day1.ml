open! Core
open! Hardcaml
open! Signal

let in_bits = 10
let out_bits = 16

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; left : 'a
    ; data_in : 'a [@bits in_bits]
    ; data_valid : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { 
      count : 'a [@bits out_bits]
      ;ready : 'a
    }
  [@@deriving hardcaml]
end

module States = struct
  type t = 
    | Idle
    | Calculating
    | Check_zero
  [@@deriving sexp_of, compare ~localize, enumerate]
end

let create scope ({clock; clear; left; data_in; data_valid;} : _ I.t) : _ O.t
=
  let spec = Reg_spec.create ~clock ~clear () in

  let open Always in
  let sm = State_machine.create (module States) spec in
  
  let%hw_var position = Variable.reg spec ~width:7 ~clear_to: (of_int_trunc ~width:7 50) in
  let%hw_var count = Variable.reg spec ~width:out_bits in
  let%hw_var temp_val = Variable.reg spec ~width:(in_bits+2) in
  let%hw_var ready = Variable.wire ~default:gnd () in
  
  let pos_s = uresize position.value ~width: (in_bits+2) -- "pos_s" in
  let data_s = uresize data_in ~width:(in_bits+2) -- "data_s" in
  let target_val = mux2 left (pos_s -: data_s) (pos_s +: data_s) -- "target val" in

  let () = compile[
    sm.switch [
      (Idle, [
        ready <-- vdd;
        when_ data_valid [
          temp_val <-- target_val;
          sm.set_next Calculating;
        ]
      ]);
      (Calculating, [
        if_ (temp_val.value >=+. 100)
          [temp_val <-- temp_val.value -:. 100]
          [
          (if_ (temp_val.value <+. 0))
            [(temp_val <-- temp_val.value +:. 100)]
            [
              position <-- uresize temp_val.value ~width:7;
              sm.set_next Check_zero
            ]
          ]
      ]);
      (Check_zero, [
        when_ (position.value ==:. 0)[
          count <-- count.value +:. 1
        ];
        sm.set_next Idle
      ])
    ]
  ] in

  {O.count = count.value; ready = ready.value}
;;
let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"day1part1" create
;;
