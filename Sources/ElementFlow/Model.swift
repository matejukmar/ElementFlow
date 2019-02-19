import Foundation

public struct Point {
  public var x: Double
  public var y: Double
}

public struct Size {
  public var width: Double
  public var height: Double
}

public struct Rect {
  public var origin: Point
  public var size: Size
  
  public init(x: Double, y: Double, width: Double, height: Double) {
    self.origin = Point(x: x, y: y)
    self.size = Size(width: width, height: height)
  }
}

public enum Direction {
  case horizontal
  case vertical
}

public enum Distribution {
  case start
  case end
  case center
  case spaceBetween
  case spaceAround
  case spaceAroundHalf
}

public enum Alignment {
  case start
  case end
  case center
  case fit
  case extend
}

public struct Inset {
  public var start: Double
  public var end: Double
  
  public init(_ value: Double) {
    self.start = value
    self.end = value
  }
  
  public init(start: Double, end: Double) {
    self.start = start
    self.end = end
  }
}

public struct Padding {
  public var left: Double
  public var top: Double
  public var right: Double
  public var bottom: Double
  
  public init() {
    left = 0
    right = 0
    top = 0
    bottom = 0
  }
  
  public init(left: Double = 0, top: Double = 0, right: Double = 0, bottom: Double = 0) {
    self.left = left
    self.top = top
    self.right = right
    self.bottom = bottom
  }
  
  public init(horizontal: Double) {
    left = horizontal
    right = horizontal
    top = 0
    bottom = 0
  }
}

public struct Shift {
  public var left: Double
  public var up: Double
  public var right: Double
  public var down: Double
  
  public init(left: Double = 0, up: Double = 0, right: Double = 0, down: Double = 0) {
    self.left = left
    self.up = up
    self.right = right
    self.down = down
  }  
}

public struct Flex {
  public var value: Double
  public init(_ val: Double) {
    self.value = val
  }
}
