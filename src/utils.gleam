import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub type Matrix =
  List(Point)

// #(Is_X, Is_Increasing)
pub type Direction =
  #(Bool, Bool)

pub type Point =
  #(String, Int, Int)

pub type Axis {
  X
  Y
}

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

pub fn read_numbers(path: String) -> List(Int) {
  let input = simplifile.read(path)
  case input {
    Ok(input) ->
      input
      |> string.trim
      |> string.split(" ")
      |> list.map(fn(s) { result.unwrap(int.parse(s), 0) })

    Error(_) -> []
  }
}

pub fn read_characters(path: String) -> List(String) {
  let input = simplifile.read(path)
  case input {
    Ok(input) ->
      input
      |> string.trim
      |> string.to_graphemes
    Error(_) -> []
  }
}

pub fn read_single_line(path: String) -> String {
  let input = simplifile.read(path)
  case input {
    Ok(input) ->
      input
      |> string.trim
    Error(_) -> ""
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

pub fn point_compare(p1: Point, p2: Point, axis: Axis, asc: Bool) {
  case axis {
    X ->
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
    Y ->
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
    list.sort(matrix, fn(a, b) { point_compare(a, b, X, True) })
    |> list.last
  let assert Ok(max_y) =
    list.sort(matrix, fn(a, b) { point_compare(a, b, Y, True) })
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
      |> list.sort(fn(a, b) { point_compare(a, b, X, True) })
      |> list.map(fn(point) { point.0 })
      |> string.join("")
    })
    |> string.join("\n")

  simplifile.write(path, file)
}

pub fn adjacent_points(
  point: Point,
  matrix: Matrix,
  predicate: fn(Point) -> Bool,
) {
  matrix
  |> list.filter(fn(compare_point) {
    {
      {
        compare_point.2 == point.2
        && { compare_point.1 == point.1 + 1 || compare_point.1 == point.1 - 1 }
      }
      || {
        compare_point.1 == point.1
        && { compare_point.2 == point.2 + 1 || compare_point.2 == point.2 - 1 }
      }
    }
    && predicate(compare_point)
  })
}

pub fn extract_all_numbers(text: String) {
  let assert Ok(re) = regexp.from_string("-?\\d+")
  regexp.scan(with: re, content: text)
  |> list.map(fn(match) {
    let assert Ok(i) = int.parse(match.content)
    i
  })
}
