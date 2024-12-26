import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import utils/coord.{type Coord, Coord}

pub fn from_string(
  input: String,
  parser: fn(String) -> Result(a, b),
) -> Dict(Coord, a) {
  {
    use row, r <- list.index_map(string.split(input, "\n"))
    use col, c <- list.index_map(string.to_graphemes(row))
    case parser(col) {
      Ok(result) -> Ok(#(Coord(c, r), result))
      Error(_) -> Error(Nil)
    }
  }
  |> list.flatten
  |> result.values
  |> dict.from_list
}
