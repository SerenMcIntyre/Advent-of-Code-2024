import gleam/io
import gleam/list
import utils.{type Matrix, type Point}

type Plot =
  List(Point)

fn build_plot_from(
  search_area: Plot,
  plot: Plot,
  matrix: Matrix,
) -> #(Plot, Matrix) {
  case search_area {
    [] -> #(plot, matrix)
    [head, ..tail] -> {
      let adjacent =
        utils.adjacent_points(head, matrix, fn(p) { p.0 == head.0 })
      let remaining_points =
        matrix
        |> list.filter(fn(p) {
          list.find(adjacent, fn(a) { a == p }) == Error(Nil)
        })
      let search_area = list.append(tail, adjacent)
      let plot = list.append(plot, adjacent)
      build_plot_from(search_area, plot, remaining_points)
    }
  }
}

// This will be inefficient as heck, but let's roll with it for now
fn get_plot_pairs(plot: Plot) {
  plot
  |> list.combination_pairs
  |> list.filter(fn(pair) {
    {
      pair.0.2 == pair.1.2
      && { pair.0.1 == pair.1.1 + 1 || pair.0.1 == pair.1.1 - 1 }
    }
    || {
      pair.0.1 == pair.1.1
      && { pair.0.2 == pair.1.2 + 1 || pair.0.2 == pair.1.2 - 1 }
    }
  })
}

fn get_basic_plot_cost(plot: Plot) -> Int {
  let plot_pairs =
    get_plot_pairs(plot)
    |> list.length
  let plot_area = plot |> list.length
  let perimeter = {
    { plot_area * 4 } - { plot_pairs * 2 }
  }
  plot_area * perimeter
}

fn point_at_offset_exists(
  point: Point,
  offset: #(Int, Int),
  original: Plot,
) -> Bool {
  let #(xdif, ydif) = offset
  let #(_, x, y) = point
  original
  |> list.any(fn(p) {
    let #(_, xprime, yprime) = p
    xprime == x + xdif && yprime == y + ydif
  })
}

fn empty_points_exist(
  point: Point,
  original: Plot,
  offsets: List(#(Int, Int)),
) -> Bool {
  offsets
  |> list.all(fn(offset) { !point_at_offset_exists(point, offset, original) })
}

fn filled_points_exist(
  point: Point,
  original: Plot,
  offsets: List(#(Int, Int)),
) -> Bool {
  offsets
  |> list.all(fn(offset) { point_at_offset_exists(point, offset, original) })
}

fn count_corners_for_point(point: Point, original: Plot) -> Int {
  let tr = empty_points_exist(point, original, [#(1, 0), #(0, -1), #(1, -1)])
  let br = empty_points_exist(point, original, [#(1, 0), #(0, 1), #(1, 1)])
  let bl = empty_points_exist(point, original, [#(-1, 0), #(0, 1), #(-1, 1)])
  let tl = empty_points_exist(point, original, [#(-1, 0), #(0, -1), #(-1, -1)])

  let inner_tr =
    filled_points_exist(point, original, [#(1, 0), #(0, -1)])
    && !point_at_offset_exists(point, #(1, -1), original)
  let inner_br =
    filled_points_exist(point, original, [#(1, 0), #(0, 1)])
    && !point_at_offset_exists(point, #(1, 1), original)
  let inner_bl =
    filled_points_exist(point, original, [#(-1, 0), #(0, 1)])
    && !point_at_offset_exists(point, #(-1, 1), original)
  let inner_tl =
    filled_points_exist(point, original, [#(-1, 0), #(0, -1)])
    && !point_at_offset_exists(point, #(-1, -1), original)

  let touching_corner_tr =
    empty_points_exist(point, original, [#(1, 0), #(0, -1)])
    && point_at_offset_exists(point, #(1, -1), original)

  let touching_corner_br =
    empty_points_exist(point, original, [#(1, 0), #(0, 1)])
    && point_at_offset_exists(point, #(1, 1), original)

  let touching_corner_bl =
    empty_points_exist(point, original, [#(-1, 0), #(0, 1)])
    && point_at_offset_exists(point, #(-1, 1), original)

  let touching_corner_tl =
    empty_points_exist(point, original, [#(-1, 0), #(0, -1)])
    && point_at_offset_exists(point, #(-1, -1), original)

  [
    tr,
    br,
    bl,
    tl,
    inner_tr,
    inner_br,
    inner_bl,
    inner_tl,
    touching_corner_tr,
    touching_corner_br,
    touching_corner_bl,
    touching_corner_tl,
  ]
  |> list.filter(fn(x) { x })
  |> list.length
}

fn count_corners(search_area: List(Point), original: Plot) {
  case search_area {
    [] -> 0
    [head, ..tail] -> {
      let corners = count_corners_for_point(head, original)
      corners + count_corners(tail, original)
    }
  }
}

fn get_discount_plot_cost(plot: Plot) -> Int {
  let sides = count_corners(plot, plot)
  let plot_area = plot |> list.length
  plot_area * sides
}

fn trace_plots(matrix: Matrix, cost_fn: fn(Matrix) -> Int) -> Int {
  case matrix {
    [] -> 0
    [head, ..tail] -> {
      let #(plot, matrix) = build_plot_from([head], [head], tail)
      cost_fn(plot) + trace_plots(matrix, cost_fn)
    }
  }
}

pub fn part1() {
  utils.read_as_lines("src/input/day12.txt")
  |> utils.convert_to_psuedo_matrix
  |> trace_plots(get_basic_plot_cost)
  |> io.debug
}

pub fn part2() {
  utils.read_as_lines("src/input/day12.txt")
  |> utils.convert_to_psuedo_matrix
  |> trace_plots(get_discount_plot_cost)
  |> io.debug
}
