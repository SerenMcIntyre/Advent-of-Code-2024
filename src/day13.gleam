import gleam/int
import gleam/io
import gleam/string
import utils

pub fn parse_equation(input: String, separator: String) -> #(Int, Int) {
  let xdent = "X" <> separator
  let ydent = "Y" <> separator
  let x_start =
    string.crop(input, xdent)
    |> string.replace(xdent, "")
  let y_start =
    string.crop(input, ydent)
    |> string.replace(ydent, "")
  let assert Ok(#(x_start, _)) = string.split_once(x_start, ",")
  case int.parse(x_start), int.parse(y_start) {
    Ok(x), Ok(y) -> {
      #(x, y)
    }
    _, _ -> panic as "Invalid equation format"
  }
}

pub fn solve(a: String, b: String, result: String) {
  // Coefficient matrices
  let #(ax, ay) = parse_equation(a, "+")

  let #(bx, by) = parse_equation(b, "+")

  // Constant matrix
  let #(cx, cy) = parse_equation(result, "=")

  // Comment out for part 1
  let #(cx, cy) = #(cx + 10_000_000_000_000, cy + 10_000_000_000_000)

  let d = ax * by - ay * bx
  let da = cx * by - cy * bx
  let db = ax * cy - ay * cx

  let #(x, y) = case da % d, db % d {
    0, 0 -> #(da / d, db / d)
    _, _ -> #(0, 0)
  }

  { x * 3 } + y
}

fn solve_equations(input: List(String)) {
  case input {
    [] -> 0
    [_] -> panic as "Invalid Inputa"
    [_, _] -> panic as "Invalid Inputb"
    [a, b, c] -> {
      solve(a, b, c)
    }
    [a, b, result, _spacer, ..tail] -> {
      solve(a, b, result) + solve_equations(tail)
    }
  }
}

pub fn run() {
  utils.read_as_lines("src/input/day13.txt")
  |> solve_equations
  |> io.debug
}
