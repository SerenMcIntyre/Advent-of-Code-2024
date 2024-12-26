import utils/velocity.{type Velocity}

pub type Coord {
  Coord(x: Int, y: Int)
}

pub fn move(coord: Coord, dir: Velocity) -> Coord {
  Coord(coord.x + dir.x, coord.y + dir.y)
}
