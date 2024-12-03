import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp.{type Match}
import gleam/string
import simplifile

pub fn apply_mul(match: Match) {
  list.map(match.submatches, fn(submatch) {
    case submatch {
      Some(num) -> int.parse(num)
      None -> Error(Nil)
    }
  })
  |> list.fold(1, fn(acc, num) {
    case num {
      Ok(num) -> num * acc
      Error(_) -> 0
    }
  })
}

pub fn part1() {
  let assert Ok(input) = simplifile.read("src/day3/input.txt")
  let assert Ok(pattern) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  regexp.scan(pattern, input)
  |> list.map(fn(match) { apply_mul(match) })
  |> list.fold(0, fn(acc, num) { acc + num })
  |> io.debug
}

pub fn process_co(line: String) {
  let assert Ok(pattern) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  regexp.scan(pattern, line)
  |> list.map(fn(match) { apply_mul(match) })
  |> list.fold(0, fn(acc, num) { acc + num })
}

pub fn part2() {
  let assert Ok(input) = simplifile.read("src/day3/input.txt")
  string.split(input, "don't()")
  |> list.map(fn(line) {
    case string.split_once(line, "do()") {
      Ok(pair) -> {
        let #(_, dopart) = pair
        process_co(dopart)
      }
      Error(Nil) -> 0
    }
  })
  |> list.fold(0, fn(acc, num) { acc + num })
  |> io.debug
}
