import utils/rotation.{type Rotation, Clockwise, CounterClockwise}

pub type Velocity {
  Velocity(x: Int, y: Int)
}

pub fn rotate(vector: Velocity, direction: Rotation) -> Velocity {
  case direction {
    Clockwise -> Velocity(vector.y, -vector.x)
    CounterClockwise -> Velocity(-vector.y, vector.x)
  }
}
