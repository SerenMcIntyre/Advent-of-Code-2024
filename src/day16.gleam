import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/order.{type Order}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleamy/priority_queue.{type Queue}
import utils
import utils/coord.{type Coord}
import utils/grid
import utils/rotation
import utils/velocity.{type Velocity, Velocity}

pub type Tile {
  Path
  Start
  End
}

pub type State {
  State(coord: Coord, dir: Velocity)
}

pub type Reindeer {
  Reindeer(coord: Coord, dir: Velocity, score: Int, path: List(Coord))
}

pub fn parse(input: String) -> Dict(Coord, Tile) {
  grid.from_string(input, fn(c) {
    case c {
      "." -> Ok(Path)
      "S" -> Ok(Start)
      "E" -> Ok(End)
      _ -> Error(Nil)
    }
  })
}

pub fn walk(
  start_with queue: Queue(Reindeer),
  through maze: Dict(Coord, Tile),
  costs costs: Dict(State, Int),
  visited visited: Set(State),
  goal goal: Coord,
  current_best best: Int,
  current_paths best_paths: List(List(Coord)),
) -> #(Int, List(List(Coord))) {
  case priority_queue.pop(queue) {
    Error(_) -> {
      // io.debug(costs)
      #(best, best_paths)
    }
    Ok(#(Reindeer(coord, dir, score, path) as reindeer, queue)) -> {
      let costs =
        dict.upsert(costs, State(coord, dir), fn(v) {
          case v {
            option.Some(old_score) -> int.min(old_score, score)
            option.None -> score
          }
        })

      case goal == coord {
        True -> {
          io.debug(#("goal", coord, dir, score, best))
          let #(best, best_paths) = case score < best, best == score {
            True, _ -> #(score, [path, ..best_paths])
            False, True -> {
              #(best, [path, ..best_paths])
            }
            False, False -> #(best, best_paths)
          }
          walk(queue, maze, costs, visited, goal, best, best_paths)
        }
        False -> {
          let visited = set.insert(visited, State(coord, dir))

          let move = coord.move(coord, dir)
          let ahead = case dict.get(maze, move) {
            Ok(_) -> [
              Reindeer(
                ..reindeer,
                coord: move,
                score: score + 1,
                path: [move, ..path],
              ),
            ]
            Error(_) -> []
          }

          let next_queue =
            [
              Reindeer(
                ..reindeer,
                dir: velocity.rotate(dir, rotation.CounterClockwise),
                score: score + 1000,
              ),
              Reindeer(
                ..reindeer,
                dir: velocity.rotate(dir, rotation.Clockwise),
                score: score + 1000,
              ),
              ..ahead
            ]
            |> list.filter(fn(r) {
              case dict.get(costs, State(r.coord, r.dir)) {
                Ok(cost) -> r.score <= cost
                Error(_) -> True
              }
            })
            |> list.fold(queue, priority_queue.push)

          walk(next_queue, maze, costs, visited, goal, best, best_paths)
        }
      }
    }
  }
}

pub fn part1() {
  let maze =
    utils.read_single_line("src/input/day16_smoller.txt")
    |> parse

  let assert [start] =
    dict.filter(maze, fn(_, tile) { tile == Start })
    |> dict.keys

  let assert [goal] =
    dict.filter(maze, fn(_, tile) { tile == End })
    |> dict.keys

  let initial_queue =
    priority_queue.new(compare_reindeer)
    |> priority_queue.push(Reindeer(start, Velocity(x: 1, y: 0), 0, [start]))

  walk(
    current_best: 9_999_999_999,
    costs: dict.new(),
    goal: goal,
    through: maze,
    start_with: initial_queue,
    visited: set.new(),
    current_paths: [],
  ).0
  |> io.debug
}

pub fn part2() {
  let maze =
    utils.read_single_line("src/input/day16.txt")
    |> parse

  let assert [start] =
    dict.filter(maze, fn(_, tile) { tile == Start })
    |> dict.keys

  let assert [goal] =
    dict.filter(maze, fn(_, tile) { tile == End })
    |> dict.keys

  let initial_queue =
    priority_queue.new(compare_reindeer)
    |> priority_queue.push(Reindeer(start, Velocity(x: 1, y: 0), 0, [start]))

  let res =
    walk(
      current_best: 9_999_999_999,
      costs: dict.new(),
      goal: goal,
      through: maze,
      start_with: initial_queue,
      visited: set.new(),
      current_paths: [],
    )

  io.debug(res.0)
  io.debug(res.1 |> list.length)
  io.debug(res.1)
  io.debug(res.1 |> list.flatten |> set.from_list |> set.size)
  // let reversed =
  //   walk(
  //     current_best: 9_999_999_999,
  //     costs: dict.new(),
  //     goal: [#(start, Velocity(1, 0)), #(start, Velocity(-1, 0))],
  //     through: maze,
  //     start_with: priority_queue.new(compare_reindeer)
  //       |> priority_queue.push(Reindeer(goal, Velocity(x: 0, y: 1), 0, [goal])),
  //     visited: set.new(),
  //     current_paths: [],
  //   )

  // reversed.1
  // |> io.debug
}

fn compare_reindeer(a: Reindeer, b: Reindeer) -> Order {
  int.compare(a.score, b.score)
}

pub fn print(maze: Dict(Coord, Tile), touched: List(Coord)) {
  let touched_set = set.from_list(touched)
  io.debug(touched |> list.length)

  // Find the dimensions of the maze
  let coords = dict.keys(maze)
  let min_x = list.fold(coords, 999_999, fn(acc, c) { int.min(acc, c.x) })
  let max_x = list.fold(coords, -999_999, fn(acc, c) { int.max(acc, c.x) })
  let min_y = list.fold(coords, 999_999, fn(acc, c) { int.min(acc, c.y) })
  let max_y = list.fold(coords, -999_999, fn(acc, c) { int.max(acc, c.y) })

  list.range(min_y - 1, max_y + 1)
  |> list.each(fn(y) {
    list.range(min_x - 1, max_x + 1)
    |> list.map(fn(x) {
      let coord = coord.Coord(x, y)
      case dict.get(maze, coord) {
        Ok(_) -> {
          case set.contains(touched_set, coord) {
            True -> "O"
            False -> "."
          }
        }
        Error(_) -> "#"
      }
    })
    |> string.join("")
    |> io.println
  })
}
