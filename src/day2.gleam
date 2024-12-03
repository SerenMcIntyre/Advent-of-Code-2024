import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn subsplit(lines: List(String)) -> List(List(Int)) {
  lines
  |> list.map(fn(line) {
    string.split(line, " ")
    |> list.map(fn(item) {
      let assert Ok(int) = int.parse(item)
      int
    })
  })
}

pub fn read_file_as_lists(file_path: String) -> List(List(Int)) {
  let assert Ok(file) = simplifile.read(file_path)
  string.trim(file)
  |> string.split(on: "\n")
  |> subsplit
}

pub fn evaluate_level_safety(
  head: Int,
  tail: List(Int),
  is_ascending: Bool,
) -> Bool {
  case tail {
    [next, ..rest] -> {
      let is_safe = evaluate_pair_safety(#(head, next), is_ascending)
      case is_safe {
        True -> evaluate_level_safety(next, rest, is_ascending)
        False -> False
      }
    }
    [] -> True
  }
}

pub fn evaluate_pair_safety(pair: #(Int, Int), is_ascending: Bool) -> Bool {
  let #(a, b) = pair
  let difference = case is_ascending {
    True -> b - a
    False -> a - b
  }
  difference >= 1 && difference <= 3
}

pub fn part1() {
  read_file_as_lists("src/Day2/input.txt")
  |> list.map(fn(level) {
    let assert Ok(first) = list.first(level)
    let assert Ok(tail) = list.rest(level)
    let assert Ok(last) = list.last(level)
    let is_ascending = first < last
    evaluate_level_safety(first, tail, is_ascending)
  })
  |> list.fold(0, fn(acc, is_safe) {
    case is_safe {
      True -> acc + 1
      False -> acc
    }
  })
  |> io.debug
}

pub fn test_level(level: List(Int)) -> Bool {
  let assert Ok(first) = list.first(level)
  let assert Ok(tail) = list.rest(level)
  let assert Ok(last) = list.last(level)
  let is_ascending = first < last
  evaluate_level_safety(first, tail, is_ascending)
}

pub fn part2() {
  read_file_as_lists("src/Day2/input.txt")
  |> list.map(fn(level) {
    let is_safe = test_level(level)
    case is_safe {
      True -> True
      False -> {
        list.combinations(level, list.length(level) - 1)
        |> list.any(fn(combination) { test_level(combination) })
      }
    }
  })
  |> list.fold(0, fn(acc, is_safe) {
    case is_safe {
      True -> acc + 1
      False -> acc
    }
  })
  |> io.debug
}
