import gleam/io
import gleam/list
import gleam/set
import utils.{type Direction, type Point}

pub fn tweens(start: Point, end: Point, free_spaces: List(Point)) -> List(Point) {
  let ascending = start.1 < end.1 || start.2 < end.2
  let axis = case start.1 != end.1 {
    True -> utils.X
    False -> utils.Y
  }

  case axis {
    utils.X ->
      list.filter(free_spaces, fn(point) {
        let #(_, x, y) = point
        y == start.2
        && case ascending {
          True -> x <= end.1 && x >= start.1
          False -> x >= end.1 && x <= start.1
        }
      })
    utils.Y ->
      list.filter(free_spaces, fn(point) {
        let #(_, x, y) = point
        x == start.1
        && case ascending {
          True -> y <= end.2 && y >= start.2
          False -> y >= end.2 && y <= start.2
        }
      })
  }
  |> list.sort(fn(a, b) { utils.point_compare(a, b, axis, ascending) })
}

pub fn next_obstacle(guard: #(Point, Direction), obstacles: List(Point)) {
  let #(start, dir) = guard
  let #(xmove, increasing) = dir
  let xmove = case xmove {
    True -> utils.X
    False -> utils.Y
  }
  let obstacles =
    list.sort(obstacles, fn(a, b) {
      utils.point_compare(a, b, xmove, increasing)
    })

  case xmove {
    utils.X ->
      list.find(obstacles, fn(point) {
        point.2 == start.2
        && case increasing {
          True -> point.1 > start.1
          False -> point.1 < start.1
        }
      })
    utils.Y -> {
      list.find(obstacles, fn(point) {
        point.1 == start.1
        && case increasing {
          True -> point.2 > start.2
          False -> point.2 < start.2
        }
      })
    }
  }
}

pub fn walk(
  guard: #(Point, Direction),
  obstacles: List(Point),
  free_spaces: List(Point),
  bottom_right: Point,
) -> List(Point) {
  case next_obstacle(guard, obstacles) {
    Error(_) -> {
      let #(gpos, gdir) = guard
      let end = case gdir {
        #(False, True) -> #("", gpos.1, bottom_right.2)
        #(False, False) -> #("", gpos.1, 0)
        #(True, True) -> #("", bottom_right.1, gpos.2)
        #(True, False) -> #("", 0, gpos.2)
      }
      tweens(gpos, end, free_spaces)
    }
    Ok(end) -> {
      let tweens = tweens(guard.0, end, free_spaces)
      let assert Ok(new_space) = list.last(tweens)
      let new_dir = case guard.1 {
        #(False, False) -> #(True, True)
        #(True, True) -> #(False, True)
        #(False, True) -> #(True, False)
        #(True, False) -> #(False, False)
      }

      list.append(
        tweens,
        walk(#(new_space, new_dir), obstacles, free_spaces, bottom_right),
      )
    }
  }
}

pub fn part1() {
  let matrix =
    utils.read_as_lines("src/input/day6.txt")
    |> utils.convert_to_psuedo_matrix

  let bottom_right = utils.matrix_end(matrix)
  let obstacles = list.filter(matrix, fn(point) { point.0 == "#" })

  let free_spaces =
    list.filter(matrix, fn(point) { point.0 == "." || point.0 == "^" })

  let assert Ok(starting_point) =
    list.find(matrix, fn(point) { point.0 == "^" })

  let visited =
    walk(
      #(starting_point, #(False, False)),
      obstacles,
      free_spaces,
      bottom_right,
    )
    |> set.from_list

  io.debug(set.size(visited))
}

pub fn test_walk_can_end(
  guard: #(Point, Direction),
  obstacles: List(Point),
  free_spaces: List(Point),
  visited: List(Point),
) -> Bool {
  case next_obstacle(guard, obstacles) {
    Error(_) -> {
      True
    }
    Ok(end) -> {
      let tweens = tweens(guard.0, end, free_spaces)
      let assert Ok(new_space) = list.last(tweens)

      let new_dir = case guard.1 {
        #(False, False) -> #(True, True)
        #(True, True) -> #(False, True)
        #(False, True) -> #(True, False)
        #(True, False) -> #(False, False)
      }

      case list.contains(visited, new_space) {
        True -> {
          case visited {
            [] -> True
            [head, ..] -> {
              case head == new_space {
                // We just turned on the spot, we can allow that
                True ->
                  test_walk_can_end(
                    #(new_space, new_dir),
                    obstacles,
                    free_spaces,
                    [new_space, ..visited],
                  )
                False -> False
              }
            }
          }
        }
        False ->
          test_walk_can_end(#(new_space, new_dir), obstacles, free_spaces, [
            new_space,
            ..visited
          ])
      }
    }
  }
}

pub fn part2() {
  let matrix =
    utils.read_as_lines("src/input/day6.txt")
    |> utils.convert_to_psuedo_matrix

  let bottom_right = utils.matrix_end(matrix)
  let obstacles = list.filter(matrix, fn(point) { point.0 == "#" })

  let free_spaces =
    list.filter(matrix, fn(point) { point.0 == "." || point.0 == "^" })

  let assert Ok(starting_point) =
    list.find(matrix, fn(point) { point.0 == "^" })

  let visited =
    walk(
      #(starting_point, #(False, False)),
      obstacles,
      free_spaces,
      bottom_right,
    )
    |> set.from_list

  set.filter(visited, fn(point) {
    point != starting_point
    && !test_walk_can_end(
      #(starting_point, #(False, False)),
      [point, ..obstacles],
      list.filter(free_spaces, fn(free_space) { free_space != point }),
      [],
    )
  })
  |> set.size
  |> io.debug
}
