import gleam/int
import gleam/io
import gleam/list
import utils

pub type Block {
  Used
  Free
}

pub fn parse_blockmap(
  input: List(String),
  blockmap: List(String),
  start: Block,
  current_id: Int,
) {
  case input {
    [] -> {
      blockmap
    }
    [head, ..tail] -> {
      let assert Ok(count) = int.parse(head)
      case start {
        Used -> {
          let blockmap =
            list.append(blockmap, list.repeat(int.to_string(current_id), count))

          parse_blockmap(tail, blockmap, Free, current_id + 1)
        }
        Free -> {
          let blockmap = list.append(blockmap, list.repeat(".", count))

          parse_blockmap(tail, blockmap, Used, current_id)
        }
      }
    }
  }
}

pub fn sort(
  sorted_blockmap: List(String),
  original_blockmap: List(String),
  bank: List(String),
  used: List(String),
) {
  case original_blockmap {
    [] -> {
      sorted_blockmap
      |> list.drop(list.length(used))
    }
    [head, ..tail] -> {
      case head == "." {
        False -> sort([head, ..sorted_blockmap], tail, bank, used)
        True -> {
          case bank {
            [] -> sort([head, ..sorted_blockmap], tail, bank, used)
            [correction, ..bank_tail] -> {
              sort([correction, ..sorted_blockmap], tail, bank_tail, [
                correction,
                ..used
              ])
            }
          }
        }
      }
    }
  }
}

pub fn sort_blockmap(blockmap: List(String)) {
  let bank =
    blockmap
    |> list.reverse
    |> list.filter(fn(block) { block != "." })

  sort([], blockmap, bank, [])
}

pub fn calculate_checksum(blockmap: List(String), position: Int) {
  case blockmap {
    [] -> 0
    [head, ..tail] -> {
      case int.parse(head) {
        Ok(id) -> id * position + calculate_checksum(tail, position + 1)
        Error(_) -> calculate_checksum(tail, position + 1)
      }
    }
  }
}

pub fn part1() {
  let input = utils.read_characters("src/input/day9.txt")

  parse_blockmap(input, [], Used, 0)
  |> sort_blockmap
  |> list.reverse
  |> calculate_checksum(0)
  |> io.debug
}

pub fn has_space(required: Int, target: List(String)) {
  target
  |> list.take(required)
  |> list.all(fn(space) { space == "." })
}

pub fn check_swap(target: List(String), group: List(String), position: Int) {
  let assert Ok(id) = list.first(group)
  case target {
    [] -> -1
    [target_head, ..target_tail] -> {
      case target_head == id {
        True -> -1
        False -> {
          case target_head == "." {
            True -> {
              case has_space(list.length(group), target) {
                True -> position
                False -> check_swap(target_tail, group, position + 1)
              }
            }
            False -> check_swap(target_tail, group, position + 1)
          }
        }
      }
    }
  }
}

pub fn perform_swap(target: List(String), group: List(String), position: Int) {
  let group_length = group |> list.length
  let assert Ok(id) = list.first(group)
  target
  |> list.index_map(fn(space, index) {
    case index >= position && index < position + group_length {
      True -> id
      False -> {
        case space == id {
          True -> "."
          False -> space
        }
      }
    }
  })
}

pub fn sort_group(sorted: List(String), bank: List(List(String))) {
  case bank {
    [] -> sorted
    [head, ..tail] -> {
      case check_swap(sorted, head, 0) {
        -1 -> sort_group(sorted, tail)
        swap_position -> {
          let sorted = perform_swap(sorted, head, swap_position)
          sort_group(sorted, tail)
        }
      }
    }
  }
}

pub fn sort_groupwise(
  blockmap: List(List(String)),
  original_blockmap: List(String),
) {
  let bank =
    blockmap
    |> list.filter(fn(block) { list.any(block, fn(b) { b != "." }) })

  sort_group(original_blockmap, bank)
}

pub fn turn_into_groups(blockmap: List(String), groups: List(List(String))) {
  case blockmap {
    [] -> {
      groups
    }
    [head, ..tail] -> {
      case groups {
        [] -> {
          turn_into_groups(tail, [[head]])
        }
        [group, ..groups_tail] -> {
          let assert Ok(id) = list.first(group)
          case head == id {
            True -> turn_into_groups(tail, [[head, ..group], ..groups_tail])
            False -> turn_into_groups(tail, [[head], ..groups])
          }
        }
      }
    }
  }
}

pub fn part2() {
  let input = utils.read_characters("src/input/day9.txt")

  let blockmap = parse_blockmap(input, [], Used, 0)
  let groups = turn_into_groups(blockmap, [])

  sort_groupwise(groups, blockmap)
  |> calculate_checksum(0)
  |> io.debug
}
