import gleam/io
import gleam/list
import gleam/set
import utils.{type Point}

pub fn get_antinodes_for_point(point: Point, antennae: List(Point), end: Point) {
  antennae
  |> list.filter(fn(p) { p.0 == point.0 && point != p })
  |> list.map(fn(target) {
    let distance = #(point.1 - target.1, point.2 - target.2)
    [
      #("#", point.1 + distance.0, point.2 + distance.1),
      #("#", target.1 - distance.0, target.2 - distance.1),
    ]
    |> list.filter(fn(p) {
      p.1 >= 0 && p.2 >= 0 && p.1 <= end.1 && p.2 <= end.2
    })
  })
  |> list.flatten
}

pub fn dig(point: Point, distance: #(Int, Int), move_forward: Bool, end: Point) {
  let new_point = case move_forward {
    True -> #("#", point.1 + distance.0, point.2 + distance.1)
    False -> #("#", point.1 - distance.0, point.2 - distance.1)
  }

  case
    new_point.1 >= 0
    && new_point.2 >= 0
    && new_point.1 <= end.1
    && new_point.2 <= end.2
  {
    True -> [new_point, ..dig(new_point, distance, move_forward, end)]
    False -> []
  }
}

pub fn get_antinodes_for_point_continuous(
  point: Point,
  antennae: List(Point),
  end: Point,
) {
  antennae
  |> list.filter(fn(p) { p.0 == point.0 && point != p })
  |> list.map(fn(target) {
    let distance = #(point.1 - target.1, point.2 - target.2)
    list.append(
      dig(target, distance, True, end),
      dig(point, distance, False, end),
    )
  })
  |> list.flatten
}

pub fn get_antinodes(antennae: List(Point), end) {
  case antennae {
    [] -> []
    [first, ..rest] -> {
      [get_antinodes_for_point(first, rest, end), ..get_antinodes(rest, end)]
    }
  }
}

pub fn get_antinodes_continuous(antennae: List(Point), end) {
  case antennae {
    [] -> []
    [first, ..rest] -> {
      [
        get_antinodes_for_point_continuous(first, rest, end),
        ..get_antinodes_continuous(rest, end)
      ]
    }
  }
}

pub fn part1() {
  let matrix =
    utils.read_as_lines("src/input/day8.txt")
    |> utils.convert_to_psuedo_matrix()

  let antennae = list.filter(matrix, fn(point) { point.0 != "." })

  let end = utils.matrix_end(matrix)
  get_antinodes(antennae, end)
  |> list.flatten
  |> set.from_list
  |> set.size
  |> io.debug
}

pub fn part2() {
  let matrix =
    utils.read_as_lines("src/input/day8.txt")
    |> utils.convert_to_psuedo_matrix()

  let antennae = list.filter(matrix, fn(point) { point.0 != "." })

  let end = utils.matrix_end(matrix)
  let antinodes =
    get_antinodes_continuous(antennae, end)
    |> list.flatten

  antinodes
  |> set.from_list
  |> set.size
  |> io.debug
}
