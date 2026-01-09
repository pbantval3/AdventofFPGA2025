open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Day1p2 = Hardcaml_demo_project.Day1p2
module Harness = Cyclesim_harness.Make (Day1p2.I) (Day1p2.O)

let in_bits = 10 (*maybe there's a way to automatically sync this with the src parameter?*)
let out_bits = 16

let parse_instruction line = 
  let char_code = String.get line 0 in
  let number_part = String.sub line ~pos:1 ~len:(String.length line - 1) in
  let amount = Int.of_string number_part in

  match char_code with
  | 'L' -> (true, amount)
  | 'R' -> (false, amount)
  | _ -> failwith ("invalid input format: " ^ line)
;;

let testbench (sim : Harness.Sim.t) = 
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let cycle () = Cyclesim.cycle sim in

  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  cycle ();

  (*put test files in tmp*)
  let instructions = In_channel.read_lines "/tmp/input.txt" in

  List.iter instructions ~f:(fun line -> 
    let (is_left, amount) = parse_instruction line in
    
    while Bits.to_int_trunc !(outputs.ready) = 0 do
      cycle ()
    done;
    inputs.left := if is_left then Bits.vdd else Bits.gnd;
    inputs.data_in := Bits.of_int_trunc ~width:in_bits amount;
    inputs.data_valid := Bits.vdd;
    cycle();
    inputs.data_valid := Bits.gnd;
    inputs.data_in := Bits.zero in_bits;
  );

  while Bits.to_int_trunc !(outputs.ready) = 0 do
    cycle()
  done;

  (*extra cycles for finish*)
  cycle();
  cycle();
  let final_count = Bits.to_int_trunc !(outputs.count) in
  print_s [%message "Complete. " (final_count : int)];
;;

let waves_config = 
  Waves_config.to_directory "/tmp/"
  |> Waves_config.as_wavefile_format ~format:Hardcamlwaveform
;;

let%expect_test "Day1p2Part1 Sim" = 
  Harness.run_advanced ~waves_config ~create:Day1p2.hierarchical testbench;
  [%expect {|
    ("Complete. " (final_count 7101))
    Saved waves to /tmp/test_day1p2_ml_Day1p2Part1_Sim.hardcamlwaveform
    |}]
;;