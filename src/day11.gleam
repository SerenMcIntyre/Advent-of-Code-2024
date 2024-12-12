import gacache
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import utils

pub fn rule_zero(stone: String, cache, n: Int) {
  case gacache.get(cache, stone <> "_" <> int.to_string(n)) {
    Ok(value) -> {
      io.debug("Cache hit")
      Ok(value)
    }
    Error(_) -> Error(Nil)
  }
}

pub fn rule_two(stone: String) -> Result(List(String), Nil) {
  let digits = string.length(stone)
  case digits % 2 == 0 {
    True -> {
      let left = string.slice(stone, 0, digits / 2)
      let right = string.drop_start(stone, digits / 2)
      // Just getting rid of potential leading zeros
      let assert Ok(right) = int.parse(right)
      let value = [left, int.to_string(right)]

      Ok(value)
    }
    _ -> Error(Nil)
  }
}

pub fn rule_three(stone: String) -> Result(List(String), Nil) {
  let assert Ok(value) = int.parse(stone)
  let value = int.to_string(value * 2024)
  Ok([value])
}

pub fn apply_rules_until_match(
  stone: String,
  rules: List(fn(String) -> Result(List(String), Nil)),
  cache,
  n: Int,
) -> List(String) {
  case rules {
    [] -> [stone]
    [rule, ..rules] -> {
      let applied = rule(stone)
      case applied {
        Ok(new_stones) -> {
          new_stones
        }
        Error(_) -> apply_rules_until_match(stone, rules, cache, n)
      }
    }
  }
}

pub fn blink_once(
  stone: String,
  cache,
  rules: List(fn(String) -> Result(List(String), Nil)),
  n: Int,
) -> List(String) {
  case stone {
    "0" -> ["1"]
    _ -> apply_rules_until_match(stone, rules, cache, n)
  }
}

pub fn manual_blink(stone, cache, rules, n) {
  let stones =
    blink_once(stone, cache, rules, n)
    |> list.map(fn(stone) { blink_n_times(stone, n - 1, cache, rules) })
    |> list.flatten

  gacache.set(cache, stone <> "_" <> int.to_string(n), stones)
  stones
}

pub fn blink_n_times(
  stone: String,
  n: Int,
  cache,
  rules: List(fn(String) -> Result(List(String), Nil)),
) -> List(String) {
  case n {
    0 -> [stone]
    _ -> {
      // case n > 30 {
      // True -> manual_blink(stone, cache, rules, n)
      // False -> {
      case gacache.get(cache, stone <> "_" <> int.to_string(n)) {
        Ok(value) -> value
        Error(_) -> manual_blink(stone, cache, rules, n)
      }
      //   }
      // }
    }
  }
}

pub fn start_blinking(stones: List(String), cache) {
  case stones {
    [] -> []
    [stone, ..stones] -> {
      io.debug(stone)
      let blinked = blink_n_times(stone, 75, cache, [rule_two, rule_three])
      [blinked, ..start_blinking(stones, cache)]
    }
  }
}

pub fn part1() {
  let stones = utils.read_words("src/input/day11.txt")

  let assert Ok(cache) = gacache.start()

  start_blinking(stones, cache)
  |> list.flatten
  |> list.length
  |> io.debug
}
