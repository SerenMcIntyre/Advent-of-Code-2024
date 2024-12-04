import gleam/io
import gleam/list
import gleam/string
import simplifile

type Cell =
  #(String, Int, Int)

type Matrix =
  List(#(String, Int, Int))

pub fn keep_digging(
  matrix: Matrix,
  x_offset: Int,
  y_offset: Int,
  x: Int,
  y: Int,
  char: String,
) -> Bool {
  let xprime = x + x_offset
  let yprime = y + y_offset
  list.any(matrix, fn(cell) {
    let #(chartest, xtest, ytest) = cell
    xtest == xprime
    && ytest == yprime
    && chartest == char
    && case chartest {
      "S" -> True
      "A" -> keep_digging(matrix, x_offset, y_offset, xprime, yprime, "S")
      _ -> False
    }
  })
}

fn search_from(x: Int, y: Int, matrix: Matrix) -> Int {
  let valid_moves =
    [
      #(x - 1, y),
      #(x + 1, y),
      #(x, y - 1),
      #(x, y + 1),
      #(x - 1, y - 1),
      #(x + 1, y + 1),
      #(x - 1, y + 1),
      #(x + 1, y - 1),
    ]
    |> list.filter(fn(move) {
      let #(x, y) = move
      x >= 0 && y >= 0
    })

  valid_moves
  |> list.map(fn(move) {
    let #(xprime, yprime) = move
    list.any(matrix, fn(cell) {
      let #(char, xtest, ytest) = cell
      xtest == xprime
      && ytest == yprime
      && char == "M"
      && keep_digging(matrix, xprime - x, yprime - y, xprime, yprime, "A")
    })
  })
  |> list.fold(0, fn(acc, found) {
    case found {
      True -> acc + 1
      False -> acc
    }
  })
}

pub fn dig(remaining: Matrix, full_matrix: Matrix) {
  case remaining {
    [target, ..rest] -> {
      let #(char, x, y) = target
      case char == "X" {
        True -> search_from(x, y, full_matrix)
        False -> 0
      }
      + dig(rest, full_matrix)
    }
    _ -> 0
  }
}

pub fn get_matrix(input: String) -> Matrix {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(char, index) { #(char, index) })
  })
  |> list.index_map(fn(row, x) {
    row
    |> list.map(fn(cell) {
      let #(char, y) = cell
      #(char, x, y)
    })
  })
  |> list.flatten
}

pub fn part1() {
  let assert Ok(input) = simplifile.read("src/input/day4.txt")

  let matrix = get_matrix(input)

  dig(matrix, matrix)
  |> io.debug
}

pub fn test_splay(diagonal: Matrix, cell: Cell) -> Bool {
  let diag_string =
    list.interleave([diagonal, [cell]])
    |> list.map(fn(test_cell) {
      let #(char, _, _) = test_cell
      char
    })
    |> string.concat

  diag_string == "MAS" || string.reverse(diag_string) == "MAS"
}

pub fn check_splay(cell: Cell, matrix: Matrix) -> Bool {
  let #(char, x, y) = cell
  let diagonal1 =
    list.filter(matrix, fn(test_cell) {
      let #(_, xprime, yprime) = test_cell
      { xprime == x + 1 && yprime == y + 1 }
      || { xprime == x - 1 && yprime == y - 1 }
    })
  let diagonal2 =
    list.filter(matrix, fn(test_cell) {
      let #(_, xprime, yprime) = test_cell
      { xprime == x - 1 && yprime == y + 1 }
      || { xprime == x + 1 && yprime == y - 1 }
    })

  test_splay(diagonal1, #(char, x, y)) && test_splay(diagonal2, #(char, x, y))
}

pub fn part2() {
  let assert Ok(input) = simplifile.read("src/input/day4.txt")

  let matrix = get_matrix(input)

  matrix
  |> list.filter(fn(cell) {
    let #(char, _, _) = cell
    char == "A"
  })
  |> list.map(fn(cell) { check_splay(cell, matrix) })
  |> list.fold(0, fn(acc, found) {
    case found {
      True -> acc + 1
      False -> acc
    }
  })
  |> io.debug
}
