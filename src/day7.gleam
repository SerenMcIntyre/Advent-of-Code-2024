import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

pub fn split(input: String) -> #(Int, List(Int)) {
  case string.split_once(input, ":") {
    Ok(parts) -> {
      let #(a, b) = parts
      let assert Ok(a) = int.parse(a)
      let b = string.trim(b)
      let b = string.split(b, " ")
      let b =
        list.map(b, fn(x) {
          let assert Ok(x) = int.parse(x)
          x
        })
      #(a, b)
    }
    Error(_) -> #(0, [])
  }
}

pub fn concat(a: Int, b: Int) {
  let assert Ok(ab) = int.parse(int.to_string(a) <> int.to_string(b))
  ab
}

pub fn dig(acc: Int, input: List(Int), target: Int) -> Bool {
  case input {
    [] -> {
      target == acc
    }
    [head, ..tail] -> {
      dig(acc + head, tail, target) || dig(acc * head, tail, target)
    }
  }
}

pub fn dig3(acc: Int, input: List(Int), target: Int) -> Bool {
  case acc > target {
    True -> False
    False ->
      case input {
        [] -> {
          target == acc
        }
        [head, ..tail] -> {
          dig3(acc + head, tail, target)
          || dig3(acc * head, tail, target)
          || dig3(concat(acc, head), tail, target)
        }
      }
  }
}

pub fn part1() {
  let input =
    utils.read_as_lines("src/input/day7.txt")
    |> list.map(fn(line) { split(line) })

  input
  |> list.filter(fn(eq) { dig(0, eq.1, eq.0) })
  |> list.fold(0, fn(acc, eq) { acc + eq.0 })
  |> io.debug
}

pub fn part2() {
  let input =
    utils.read_as_lines("src/input/day7.txt")
    |> list.map(fn(line) { split(line) })

  input
  |> list.filter(fn(eq) { dig3(0, eq.1, eq.0) })
  // res
  // |> list.each(fn(eq) { io.debug(eq) })
  // res
  |> list.fold(0, fn(acc, eq) { acc + eq.0 })
  |> io.debug
}
