import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

pub type Rule =
  #(Int, Int)

pub type Update =
  List(Int)

pub fn trim_empty(groups: #(List(String), List(String))) {
  let #(rules, updates) = groups
  let assert Ok(updates) = updates |> list.rest
  #(rules, updates)
}

pub fn parse_groups(groups: #(List(String), List(String))) {
  let #(rules, updates) = groups

  let rules =
    rules
    |> list.map(fn(rule) {
      let assert Ok(pair) = rule |> string.split_once(on: "|")
      let #(first, second) = pair
      let assert Ok(first) = int.parse(first)
      let assert Ok(second) = int.parse(second)
      #(first, second)
    })
  let updates =
    updates
    |> list.map(fn(update) {
      update
      |> string.split(",")
      |> list.map(fn(n) {
        let assert Ok(n) = int.parse(n)
        n
      })
    })

  #(rules, updates)
}

pub fn split(lines) {
  lines
  |> list.split_while(fn(line) { !string.is_empty(line) })
  |> trim_empty
  |> parse_groups
}

pub fn find_matching_tail(tail: List(Int), target: Int, is_tail: Bool) -> Bool {
  case tail {
    [head, ..tail] -> {
      case head == target {
        True -> True
        False -> find_matching_tail(tail, target, is_tail)
      }
    }
    [] -> is_tail
  }
}

pub fn update_passes_rule(update: Update, rule: Rule) -> Bool {
  case update {
    [head, ..tail] -> {
      case head == rule.1 {
        True -> !find_matching_tail(tail, rule.0, False)
        False -> {
          case head == rule.0 {
            True -> find_matching_tail(tail, rule.1, True)
            False -> update_passes_rule(tail, rule)
          }
        }
      }
    }
    [] -> True
  }
}

fn test_update(update: Update, rules: List(Rule)) {
  rules
  |> list.all(fn(rule) { update_passes_rule(update, rule) })
}

pub fn find_middle(update: Update) {
  let assert Ok(split_point) = int.divide(list.length(update), 2)
  let #(_, right) =
    update
    |> list.split(split_point)

  let assert Ok(middle) = list.first(right)
  middle
}

pub fn test_passing_updates(
  groups: #(List(Rule), List(Update)),
  expect_passing: Bool,
) {
  let #(rules, updates) = groups

  updates
  |> list.filter(fn(update) { expect_passing == test_update(update, rules) })
}

pub fn part1() {
  utils.read_as_lines("src/input/day5.txt")
  |> split
  |> test_passing_updates(True)
  |> list.map(with: find_middle)
  |> list.fold(from: 0, with: fn(acc, middle) { acc + middle })
  |> io.debug
}

pub fn swap_by_value(update: Update, value_pair: #(Int, Int)) {
  update
  |> list.map(fn(n) {
    case n == value_pair.0 {
      True -> value_pair.1
      False ->
        case n == value_pair.1 {
          True -> value_pair.0
          False -> n
        }
    }
  })
}

pub fn fix_update(update: Update, rules: List(Rule)) {
  let failed_rule =
    rules
    |> list.find(fn(rule) { !update_passes_rule(update, rule) })
  case failed_rule {
    Ok(rule) -> {
      let corrected_update = swap_by_value(update, rule)
      case rules {
        [head, ..tail] -> {
          let reordered_rules = list.append(tail, [head])
          fix_update(corrected_update, reordered_rules)
        }
        [] -> corrected_update
      }
    }
    Error(_) -> update
  }
}

pub fn fix_updates(updates: List(Update), rules: List(Rule)) {
  updates
  |> list.map(fn(update) { fix_update(update, rules) })
}

pub fn part2() {
  let #(rules, updates) =
    utils.read_as_lines("src/input/day5.txt")
    |> split

  test_passing_updates(#(rules, updates), False)
  |> fix_updates(rules)
  |> list.map(with: find_middle)
  |> list.fold(from: 0, with: fn(acc, middle) { acc + middle })
  |> io.debug()
}
