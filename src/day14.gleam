import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import utils

type Position =
  #(Int, Int)

type Velocity =
  #(Int, Int)

type Robot =
  #(Position, Velocity)

fn parse_robot(line: String) -> Robot {
  case utils.extract_all_numbers(line) {
    [x, y, xv, yv, ..] -> #(#(x, y), #(xv, yv))
    [] -> panic as "Incorrect number arity"
    [_] -> panic as "Incorrect number arity"
    [_, _] -> panic as "Incorrect number arity"
    [_, _, _] -> panic as "Incorrect number arity"
  }
}

pub fn move(robot: Robot, seconds: Int, bounds: #(Int, Int)) {
  let #(#(x, y), #(xv, yv)) = robot

  case
    int.modulo(x + xv * seconds, bounds.0),
    int.modulo(y + yv * seconds, bounds.1)
  {
    Ok(x), Ok(y) -> #(x, y)
    _, _ -> panic as "Math broke? Well, that shouldn't happen"
  }
}

pub fn count_robots_in_quadrant(
  robots: List(Position),
  quadrant: Int,
  bounds: #(Int, Int),
) {
  let xmid = {
    bounds.0 / 2
  }
  let ymid = {
    bounds.1 / 2
  }
  let quadrant_bounds = case quadrant {
    1 -> #(#(0, xmid - 1), #(0, ymid - 1))
    2 -> #(#(xmid + 1, bounds.0 - 1), #(0, ymid - 1))
    3 -> #(#(0, xmid - 1), #(ymid + 1, bounds.1 - 1))
    4 -> #(#(xmid + 1, bounds.0 - 1), #(ymid + 1, bounds.1 - 1))
    _ -> panic as "Invalid quadrant given"
  }

  robots
  |> list.filter(fn(robot) {
    let #(x, y) = robot
    x >= quadrant_bounds.0.0
    && x <= quadrant_bounds.0.1
    && y >= quadrant_bounds.1.0
    && y <= quadrant_bounds.1.1
  })
  |> list.length
}

pub fn part1() {
  let input = utils.read_as_lines("src/input/day14.txt")

  let bounds = #(101, 103)
  let seconds = 100

  let new_positions =
    input
    |> list.map(fn(line) {
      parse_robot(line)
      |> move(seconds, bounds)
    })

  list.range(1, 4)
  |> list.fold(1, fn(acc, quad) {
    acc * count_robots_in_quadrant(new_positions, quad, bounds)
  })
  |> io.debug
}

pub fn draw(robots: List(Position), i: Int, bounds: #(Int, Int)) {
  io.print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")

  list.range(0, bounds.0 - 1)
  |> list.each(fn(x) {
    list.range(0, bounds.1 - 1)
    |> list.each(fn(y) {
      let robot = list.find(robots, fn(robot) { x == robot.0 && y == robot.1 })
      case robot {
        Ok(_) -> {
          io.print("#")
        }
        _ -> io.print(" ")
      }
    })
    io.print("\n")
  })
  io.println(int.to_string(i))
}

fn get_touching_robots(robots: List(Position)) {
  list.filter(robots, fn(point) {
    list.any(robots, fn(compare_point) {
      { compare_point.0 == point.0 + 1 || compare_point.0 == point.0 - 1 }
      && { compare_point.1 == point.1 + 1 || compare_point.1 == point.1 - 1 }
    })
  })
}

pub fn part2() {
  let input = utils.read_as_lines("src/input/day14_bonus.txt")

  let bounds = #(101, 103)
  // list.range(1, 20_000)
  //#(16642, 96), #(19835, 96), #(368, 97), #(3973, 97), #(4848, 97), #(10771, 97), #(14376, 97), #(15251, 97), #(2020, 98), #(4797, 98), #(7878, 98), #(12423, 98), #(15200, 98), #(18281, 98), #(7475, 99), #(17878, 99), #(4282, 101), #(14685, 101), #(3149, 102), #(13552, 102), #(7373, 103), #(17776, 103), #(7372, 115), #(17775, 115), #(2222, 140), #(12625, 140)]
  [2222]
  |> list.map(fn(i) {
    let state =
      input
      |> list.map(fn(line) {
        parse_robot(line)
        |> move(i, bounds)
      })
    draw(state, i, bounds)
    #(i, list.length(get_touching_robots(state)))
  })
  |> list.sort(fn(a, b) { int.compare(a.1, b.1) })
  |> io.debug
}
/// Just like... find the biggest number of touching robots then draw the state and verify that it's christmas
