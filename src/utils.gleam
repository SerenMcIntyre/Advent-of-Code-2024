import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import simplifile

pub type Matrix =
  List(Point)

// #(Is_X, Is_Increasing)
pub type Direction =
  #(Bool, Bool)

pub type Point =
  #(String, Int, Int)

pub fn read_as_lines(path: String) -> List(String) {
  let input = simplifile.read(path)
  case input {
    Ok(input) ->
      input
      |> string.trim
      |> string.split("\n")
    Error(_) -> []
  }
}

// used from day6 - not going to go back and rejig day 4
pub fn convert_to_psuedo_matrix(rows: List(String)) -> Matrix {
  rows
  |> list.map(fn(line) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(char, index) { #(char, index) })
  })
  |> list.index_map(fn(row, y) {
    row
    |> list.map(fn(cell) {
      let #(char, x) = cell
      #(char, x, y)
    })
  })
  |> list.flatten
}

pub fn point_at(x: Int, y: Int, matrix: Matrix) {
  matrix
  |> list.find(fn(point) { point.1 == x && point.2 == y })
}

pub fn point_compare(p1: Point, p2: Point, compare_x: Bool, asc: Bool) {
  case compare_x {
    True ->
      case asc {
        True -> {
          case p1.1 > p2.1 {
            True -> order.Gt
            False -> order.Lt
          }
        }
        False -> {
          case p1.1 > p2.1 {
            True -> order.Lt
            False -> order.Gt
          }
        }
      }
    False ->
      case asc {
        True -> {
          case p1.2 > p2.2 {
            True -> order.Gt
            False -> order.Lt
          }
        }
        False -> {
          case p1.2 > p2.2 {
            True -> order.Lt
            False -> order.Gt
          }
        }
      }
  }
}

pub fn matrix_end(matrix: Matrix) -> Point {
  let assert Ok(max_x) =
    list.sort(matrix, fn(a, b) { point_compare(a, b, True, True) })
    |> list.last
  let assert Ok(max_y) =
    list.sort(matrix, fn(a, b) { point_compare(a, b, False, True) })
    |> list.last
  #("", max_x.1, max_y.2)
}

pub fn write_matrix_to_file(matrix: Matrix, path: String) {
  let y_vals =
    list.map(matrix, fn(point) { point.2 })
    |> list.unique

  let file =
    y_vals
    |> list.map(fn(y) {
      list.filter(matrix, fn(point) { point.2 == y })
      |> list.sort(fn(a, b) { point_compare(a, b, True, True) })
      |> list.map(fn(point) { point.0 })
      |> string.join("")
    })
    |> string.join("\n")

  simplifile.write(path, file)
}
