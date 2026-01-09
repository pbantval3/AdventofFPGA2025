open! Core
open! Hardcaml

(*Day 1 Part 1*)
val in_bits : int
val out_bits : int

module I : sig
  type 'a t = {
                clock : 'a
                ; clear : 'a
                ; left : 'a
                ; data_in : 'a
                ; data_valid : 'a
              }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = {
                count : 'a
                ; ready : 'a (*also acts as valid signal*)
              }
  [@@deriving hardcaml]
end

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
