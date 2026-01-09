# [Day 1 Advent of Code 2025](https://adventofcode.com/2025/day/1)

- This problem involves a spin lock starting at position 50. The inputs are left or right turns of the dial and the number of clicks. `L30` indicates a left rotation of 30 clicks.
- I/O and testbenches for part 1 and 2 are the same
- Python simulation of part 2 solution available

## Solution
- This was my first time using Hardcaml/Ocaml so I used a simple FSM solution for modulo. It also adapts easily for part 2.
- The current position is registered. `data_in` is added if right, and subtracted if left.
- The FSM adds or subtracts 100 from the position until 0 <= pos < 100 (<= 100 in p2)
    - 1 is added to the count each time in p2
- Then it checks for zero and returns to idle
- The solution is also scalable for larger inputs (clicks >1000) and outputs if you change `in_bits` and `out_bits` respectively.
  
## I/O
- I/O is synchronous
- Inputs are received through the `left` signal for direction (1=left, 0 = right) and the `data_in` signal with default size 10 bits (assuming <1000 clicks per input) on `data_valid`.
- The password output is delivered through a running counter; `count` signal that defaults to 16 bits (configurable).
- When the module is done processing the current input, the `ready` output flag is raised to indicate acceptance of the next rotation.

## Testbench
- The testbench takes in a file similar to the puzzle input from AoC. `sample.txt` is the example provided.
- It sends the data according to the specifications in I/O.
