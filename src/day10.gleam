import gleam/int
import gleam/io
import gleam/list
import utils.{type Matrix, type Point}

pub fn get_valid_steps(point: Point, matrix: Matrix) {
  let assert Ok(point_value) = int.parse(point.0)
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
    && int.parse(compare_point.0) == Ok(point_value + 1)
  })
}

pub fn find_nines(start: Point, matrix: Matrix) {
  case start.0 == "9" {
    True -> [start]
    False -> {
      let adjacent_points = get_valid_steps(start, matrix)

      list.map(adjacent_points, fn(point) { find_nines(point, matrix) })
      |> list.flatten
    }
  }
}

pub fn rate_trail(start: Point, matrix: Matrix) {
  case start.0 == "9" {
    True -> 1
    False -> {
      let adjacent_points = get_valid_steps(start, matrix)

      list.map(adjacent_points, fn(point) { rate_trail(point, matrix) })
      |> list.fold(0, fn(acc, score) { acc + score })
    }
  }
}

pub fn search_for_trail_entries(to_search: Matrix, matrix: Matrix) {
  case to_search {
    [] -> 0
    [head, ..tail] -> {
      case head.0 == "0" {
        True -> {
          let touched_nines =
            find_nines(head, matrix)
            |> list.unique
            |> list.length

          touched_nines + search_for_trail_entries(tail, matrix)
        }
        False -> search_for_trail_entries(tail, matrix)
      }
    }
  }
}

pub fn search_for_trail_entries2(to_search: Matrix, matrix: Matrix) {
  case to_search {
    [] -> 0
    [head, ..tail] -> {
      case head.0 == "0" {
        True -> {
          let score = rate_trail(head, matrix)

          score + search_for_trail_entries2(tail, matrix)
        }
        False -> search_for_trail_entries2(tail, matrix)
      }
    }
  }
}

pub fn part1() {
  let input = utils.read_as_lines("src/input/day10.txt")
  let matrix = utils.convert_to_psuedo_matrix(input)

  search_for_trail_entries(matrix, matrix)
  |> io.debug
}

pub fn part2() {
  let input = utils.read_as_lines("src/input/day10.txt")
  let matrix = utils.convert_to_psuedo_matrix(input)

  search_for_trail_entries2(matrix, matrix)
  |> io.debug
}
