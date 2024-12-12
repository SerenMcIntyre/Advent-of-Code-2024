import gleam/int
import gleam/io
import gleam/list
import gleam/string
import glemo
import utils

pub fn blink_once(stone: Int) -> List(Int) {
  case stone {
    0 -> [1]
    _ -> {
      let str = int.to_string(stone)
      let digits = string.length(str)
      case digits % 2 == 0 {
        True -> {
          let left = string.slice(str, 0, digits / 2)
          let right = string.drop_start(str, digits / 2)
          // Just getting rid of potential leading zeros
          let assert Ok(left) = int.parse(left)
          let assert Ok(right) = int.parse(right)
          [left, right]
        }
        False -> [stone * 2024]
      }
    }
  }
}

pub fn manual_blink(stone, n) {
  let stones =
    blink_once(stone)
    |> list.map(fn(stone) { blink_n_times(stone, n - 1) })
    |> list.fold(0, fn(acc, stone) { acc + stone })

  stones
}

pub fn blink_n_times(stone: Int, n: Int) -> Int {
  stone
  |> glemo.memo(int.to_string(n), fn(stone) {
    case n {
      0 -> 1
      _ -> {
        manual_blink(stone, n)
      }
    }
  })
}

pub fn start_blinking(stones: List(Int)) {
  case stones {
    [] -> 0
    [stone, ..stones] -> {
      io.debug(stone)
      blink_n_times(stone, 75) + start_blinking(stones)
    }
  }
}

pub fn part1() {
  let stones = utils.read_numbers("src/input/day11.txt")

  list.range(0, 75)
  |> list.map(fn(n) { int.to_string(n) })
  |> glemo.init

  start_blinking(stones)
  |> io.debug
}
