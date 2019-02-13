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
  case fill
}

public struct Margin {
  public var left: Double
  public var top: Double
  public var right: Double
  public var bottom: Double
  
  public init(left: Double = 0, top: Double = 0, right: Double = 0, bottom: Double = 0) {
    self.left = left
    self.top = top
    self.right = right
    self.bottom = bottom
  }
}

public struct Padding {
  public var left: Double
  public var top: Double
  public var right: Double
  public var bottom: Double
  
  public init(horizontal: Double) {
    left = horizontal
    right = horizontal
    top = 0
    bottom = 0
  }
}

public protocol Element {}

public protocol Flow: class, Element {
  var frame: Rect { get set }
  var flex: Double?  { get set }
  var margin: Margin?  { get set }
  var align: Alignment?  { get set }
}

public struct Flex {
  public var value: Double
  public init(_ val: Double) {
    self.value = val
  }
}

extension Double: Element {}
extension Flex: Element {}

public func flow(
  frame: Rect,
  direction: Direction, 
  distribution: Distribution, 
  align: Alignment,
  padding: Padding, 
  elements: [Element]
) {
  var totalFlex: Double = 0
  var totalFixed: Double = 0
  for element in elements {
    switch element {
    case let el as Double:
      totalFixed += el
    case let el as Flex:
      totalFlex += el.value
    case let el as Flow:
      let margin = el.margin ?? Margin(left: 0, top: 0, right: 0, bottom: 0)
      if let flex = el.flex {
        totalFlex += flex
        switch direction {
          case .horizontal:
            totalFixed += margin.left + margin.right
          case .vertical:
            totalFixed += margin.top + margin.bottom
        }
      } else {
        switch direction {
          case .horizontal:
            totalFixed += el.frame.size.width + margin.left + margin.right
          case .vertical:
            totalFixed += el.frame.size.height + margin.top + margin.bottom
        }
      }
    default:
      fatalError("wrong element type")
    }
  }

  var pos: Double
  var elements2: [Element]
  if totalFlex > 0 || distribution == Distribution.spaceBetween || distribution == Distribution.spaceAround || distribution == Distribution.spaceAroundHalf {
    // layout with flex
    pos = 0
    switch distribution {
      case .spaceAround:
        elements2 = []
        for (index, element) in elements.enumerated() {
          if index == 0 {
            elements2.append(Flex(1))
            totalFlex += 1
          }
          elements2.append(element)
          elements2.append(Flex(1))
          totalFlex += 1
        }

      case .spaceAroundHalf:
        elements2 = []
        for (index, element) in elements.enumerated() {
          if index == 0 {
            elements2.append(Flex(0.5))
            totalFlex += 0.5
          }
          elements2.append(element)
          if (index == elements.count - 1) {
            elements2.append(Flex(0.5))
            totalFlex += 0.5
          } else {
            elements2.append(Flex(1))
            totalFlex += 1
          }
        }

      case .spaceBetween:
        elements2 = []
        for (index, element) in elements.enumerated() {
          elements2.append(element)
          if index != elements.count - 1 {
            elements2.append(Flex(1))
            totalFlex += 1
          }
        }
      default:
      elements2 = elements
    }
  } else {
    // layout without flex
    elements2 = elements
    switch distribution {
      case .start:
      switch direction {
        case .horizontal:
        pos = padding.left
        case .vertical:
        pos = padding.top
      }
      case .end:
      switch direction {
        case .horizontal:
        pos = frame.size.width - totalFixed - padding.right
        case .vertical:
        pos = frame.size.height - totalFixed - padding.bottom
      }
      case .center:
      switch direction {
        case .horizontal:
        pos = padding.left + (frame.size.width - padding.left - padding.right - totalFixed)/2
        case .vertical:
        pos = padding.top + (frame.size.height - padding.top - padding.bottom - totalFixed)/2
      }
    default:
      fatalError("unsuported distribution")
  }
  }

  for element in elements2 {
    switch element {
    case let el as Double:
      pos += el
    case let el as Flex:
      switch direction {
        case .horizontal:
          pos += (frame.size.width - padding.left - padding.right - totalFixed)*el.value/totalFlex
        case .vertical:
          pos += (frame.size.height - padding.top - padding.bottom - totalFixed)*el.value/totalFlex
      }
    case let el as Flow:
      let margin = el.margin ?? Margin(left: 0, top: 0, right: 0, bottom: 0)
      let align2 = el.align ?? align
      switch direction {
        case .horizontal:
          let width: Double
          if let flex = el.flex {
            width = (frame.size.width - padding.left - padding.right - totalFixed) * flex / totalFlex
          } else {
            width = el.frame.size.width
          }
          switch align2 {
            case .start:
              el.frame = Rect(
                x: pos + margin.left, 
                y: padding.top + margin.top, 
                width: width, 
                height: el.frame.size.height
              )
            case .end:
              el.frame = Rect(
                x: pos + margin.left, 
                y: frame.size.height - padding.bottom - el.frame.size.height - margin.bottom, 
                width: width, 
                height: el.frame.size.height
              )
            case .center:
              el.frame = Rect(
                x: pos + margin.left, 
                y: padding.top + margin.top + (frame.size.height - margin.top - margin.bottom - padding.top - padding.bottom - el.frame.size.height)/2, 
                width: width, 
                height: el.frame.size.height
              )
            case .fill:
              el.frame = Rect(
                x: pos + margin.left, 
                y: padding.top + margin.top, 
                width: width, 
                height: frame.size.height - padding.top - margin.top - padding.bottom - margin.bottom
              )
          }
           pos += width + margin.left + margin.right
        case .vertical:
          let height: Double
          if let flex = el.flex {
            height = (frame.size.height - padding.top - padding.bottom - totalFixed)*flex/totalFlex
          } else {
            height = el.frame.size.height
          }
          switch align2 {
            case .start:
              el.frame = Rect(
                x: padding.left + margin.left, 
                y: pos + margin.top, 
                width: el.frame.size.width, 
                height: height
              )
            case .end:
              el.frame = Rect(
                x: frame.size.width - padding.right - margin.right - el.frame.size.width, 
                y: pos + margin.top, 
                width: el.frame.size.width, 
                height: height
              )
            case .center:
              el.frame = Rect(
                x: padding.left + margin.left + (frame.size.width - padding.left - padding.right - margin.left - margin.right - el.frame.size.height)/2, 
                y: pos + margin.top, 
                width: el.frame.size.width, 
                height: height
              )
            case .fill:
              el.frame = Rect(
                x: padding.left + margin.left, 
                y: pos + margin.top, 
                width: frame.size.width - padding.left - padding.right - margin.left - margin.right, 
                height: height
              )
          }
          pos += height + margin.top + margin.bottom
        }
    default:
      fatalError("not supported")
      }
    }
  }
