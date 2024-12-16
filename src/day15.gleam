import gleam/io
import gleam/list
import gleam/result
import gleam/string
import utils.{type Coordinate, type Point}

pub fn gather_affected(
  point: Coordinate,
  obstacles: List(Point),
  direction: Coordinate,
) -> List(#(Point, Coordinate)) {
  let affected =
    list.find(obstacles, fn(o) { o.1 == point.0 && o.2 == point.1 })

  case affected {
    Ok(obs) -> {
      // io.debug("Source")
      // io.debug(obs)
      let dir = convert_to_dir_symbol(direction)
      // io.debug(dir)
      let friends = case obs.0 {
        "[" -> {
          case dir != ">" && dir != "<" {
            True -> Ok(#("]", obs.1 + 1, obs.2))
            False -> Error(Nil)
            // If we're heading that way anyway, the other box half will land up included
          }
        }
        "]" -> {
          case dir != "<" && dir != ">" {
            True -> Ok(#("[", obs.1 - 1, obs.2))
            False -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
      case dir {
        "^" -> {
          io.debug(#("friends", friends, obs))
          0
        }
        _ -> 0
      }

      let part1 = case friends {
        Ok(friend) -> {
          let new_friend = utils.add(#(friend.1, friend.2), direction)
          [
            #(friend, new_friend),
            ..gather_affected(new_friend, obstacles, direction)
          ]
        }
        Error(_) -> []
      }
      let new_point = utils.add(#(obs.1, obs.2), direction)
      let affected = [
        #(obs, new_point),
        ..gather_affected(new_point, obstacles, direction)
      ]
      list.append(part1, affected)
    }
    Error(_) -> []
  }
}

pub fn process_move(
  robot: Coordinate,
  obstacles: List(Point),
  direction: Coordinate,
) {
  let next_point = utils.add(robot, direction)
  io.debug(#(robot, "->", next_point))
  let affected = gather_affected(next_point, obstacles, direction)
  io.debug(#("Affected", affected))
  case affected {
    [] -> {
      #(next_point, obstacles)
    }
    [_, ..] -> {
      case list.all(affected, fn(update) { update.0.0 != "#" }) {
        True -> {
          let new_boxes =
            list.map(obstacles, fn(obstacle) {
              let to_update =
                list.find(affected, fn(update) { obstacle == update.0 })

              case to_update {
                Ok(update) -> {
                  #(update.0.0, update.1.0, update.1.1)
                }
                Error(_) -> obstacle
              }
            })
          #(next_point, new_boxes)
        }
        False -> {
          io.debug("Can't move")
          #(robot, obstacles)
        }
      }
    }
  }
}

pub fn convert_to_dir_symbol(dir: Coordinate) {
  case dir {
    #(1, 0) -> ">"
    #(0, 1) -> "v"
    #(-1, 0) -> "<"
    #(0, -1) -> "^"
    _ -> ""
  }
}

pub fn process_moves(
  robot: Coordinate,
  obstacles: List(Point),
  instructions: List(Coordinate),
) {
  case instructions {
    [] -> #(robot, obstacles)
    [head, ..tail] -> {
      io.debug(convert_to_dir_symbol(head))
      let #(next_robot, next_obstacles) = process_move(robot, obstacles, head)
      io.debug("State")
      io.debug(next_robot)
      io.debug(list.filter(next_obstacles, fn(o) { o.0 == "[" || o.0 == "]" }))

      process_moves(next_robot, next_obstacles, tail)
    }
  }
}

pub fn score(box_coord: Coordinate) {
  let #(x, y) = box_coord
  x + y * 100
}

pub fn part1() {
  let input = utils.read_as_lines("src/input/day15.txt")

  let map =
    list.take_while(input, fn(line) { line != "" })
    |> utils.convert_to_psuedo_matrix

  let robot =
    result.unwrap(
      list.find_map(map, fn(row) {
        case row.0 == "@" {
          True -> Ok(#(row.1, row.2))
          False -> Error(Nil)
        }
      }),
      #(0, 0),
    )
  let obstacles =
    list.filter_map(map, fn(row) {
      case row.0 == "#" || row.0 == "O" {
        True -> Ok(row)
        False -> Error(Nil)
      }
    })

  let instructions =
    list.drop_while(input, fn(line) { line != "" })
    |> list.map(fn(line) { string.split(line, "") })
    |> list.flatten
    |> list.map(fn(direction) {
      case direction {
        "<" -> #(-1, 0)
        ">" -> #(1, 0)
        "^" -> #(0, -1)
        "v" -> #(0, 1)
        _ -> panic as "Invalid direction"
      }
    })

  let final_state = process_moves(robot, obstacles, instructions)

  let #(final_robot, final_obstacles) = final_state
  final_obstacles
  |> list.filter(fn(o) { o.0 == "O" })
  |> list.map(fn(o) { score(#(o.1, o.2)) })
  |> list.fold(0, fn(acc, score) { acc + score })
  |> io.debug
}

pub fn part2() {
  let input = utils.read_as_lines("src/input/day15_mod.txt")

  let map =
    list.take_while(input, fn(line) { line != "" })
    |> utils.convert_to_psuedo_matrix

  let robot =
    result.unwrap(
      list.find_map(map, fn(row) {
        case row.0 == "@" {
          True -> Ok(#(row.1, row.2))
          False -> Error(Nil)
        }
      }),
      #(0, 0),
    )
  let obstacles =
    list.filter_map(map, fn(row) {
      case row.0 == "#" || row.0 == "[" || row.0 == "]" {
        True -> Ok(row)
        False -> Error(Nil)
      }
    })

  let instructions =
    list.drop_while(input, fn(line) { line != "" })
    |> list.map(fn(line) { string.split(line, "") })
    |> list.flatten
    |> list.map(fn(direction) {
      case direction {
        "<" -> #(-1, 0)
        ">" -> #(1, 0)
        "^" -> #(0, -1)
        "v" -> #(0, 1)
        _ -> panic as "Invalid direction"
      }
    })

  let final_state = process_moves(robot, obstacles, instructions)

  let #(final_robot, final_obstacles) = final_state
  final_obstacles
  |> list.filter(fn(o) { o.0 == "[" })
  |> list.map(fn(o) { score(#(o.1, o.2)) })
  |> list.fold(0, fn(acc, score) { acc + score })
  |> io.debug

  final_robot
  |> io.debug
}
