import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn read_file_as_list_pair(path: String) -> #(List(Int), List(Int)) {
  let assert Ok(file_contents) = simplifile.read(path)

  string.trim(file_contents)
  |> string.split("\n")
  |> list.map(fn(line) { string.split(line, "   ") })
  |> list.map(fn(pair) {
    case pair {
      [a, b] -> #(int.parse(a), int.parse(b))
      _ -> panic as "Invalid input"
    }
  })
  |> list.filter_map(fn(pair) {
    case pair {
      #(Ok(a), Ok(b)) -> Ok(#(a, b))
      _ -> Error(Nil)
    }
  })
  |> list.unzip()
}

pub fn sort(pair: #(List(Int), List(Int))) -> #(List(Int), List(Int)) {
  let #(first, second) = pair
  let first = list.sort(first, int.compare)
  let second = list.sort(second, int.compare)
  #(first, second)
}

pub fn get_pair_differences(pair: #(List(Int), List(Int))) -> List(Int) {
  let #(first, second) = pair
  list.zip(first, second)
  |> list.map(fn(pair) {
    let #(a, b) = pair
    case a > b {
      True -> a - b
      False -> b - a
    }
  })
}

pub fn part1() {
  read_file_as_list_pair("src/Day1/input.txt")
  |> sort
  |> get_pair_differences
  |> list.fold(0, fn(acc, diff) { acc + diff })
  |> io.debug
}

pub fn part2() {
  read_file_as_list_pair("src/Day1/input.txt")
  |> get_similarity_scores
  |> list.fold(0, fn(acc, score) { acc + score })
  |> io.debug
}

fn get_similarity_scores(pair: #(List(Int), List(Int))) -> List(Int) {
  let #(first, second) = pair
  list.map(first, fn(a) { a * frequency(second, a) })
}

fn frequency(list: List(Int), value: Int) -> Int {
  list.filter(list, fn(v) { v == value })
  |> list.length
}
