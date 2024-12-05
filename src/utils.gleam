import gleam/string
import simplifile

pub fn read_as_lines(path: String) -> List(String) {
  let input = simplifile.read(path)
  case input {
    Ok(input) ->
      input
      |> string.trim
      |> string.split("\n")
    Error(_) -> []
  }
}
