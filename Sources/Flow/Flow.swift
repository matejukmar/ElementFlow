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

  public init(horizontal: Double = 0, vertical: Double = 0) {
    self.left = horizontal
    self.top = vertical
    self.right = horizontal
    self.bottom = vertical
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

  public init(horizontal: Double) {
    left = horizontal
    right = horizontal
    top = 0
    bottom = 0
  }
}

public protocol ElementType {}

public protocol Element: class, ElementType {
  var frame: Rect { get set }
  var flex: Double?  { get set }
  var margin: Margin  { get set }
  var align: Alignment?  { get set }
}

public struct FlowElementProps {
  var flex: Double?
  var margin: Margin?
  var align: Alignment?
  
  public init(flex: Double? = nil, margin: Margin? = nil, align: Alignment? = nil) {
    self.flex = flex
    self.margin = margin
    self.align = align
  }
}

public struct Flex {
  public var value: Double
  public init(_ val: Double) {
    self.value = val
  }
}

extension Double: ElementType {}
extension Flex: ElementType {}

public class Flow: Element {
  public var frame: Rect {
    didSet {
      print("I have changed frame222", frame)
      flow(
        frame: frame,
        direction: direction,
        distribution: distribution,
        align: flowAlign,
        padding: padding,
        elements: elements
      )
    }
  }

  //props as flow container
  public var direction: Direction
  public var distribution: Distribution
  public var flowAlign: Alignment
  public var padding: Padding

  //props as flow element
  public var flex: Double?
  public var margin: Margin
  public var align: Alignment?
  
  
  var elements: [ElementType]

  public init(
    size: (Double, Double)? = nil,
    direction: Direction,
    distribution: Distribution = .start,
    flowAlign: Alignment = .start,
    padding: Padding = Padding(),
    flex: Double? = nil,
    margin: Margin = Margin(),
    align: Alignment? = nil,
    elements: [ElementType]
  ) {
    let w, h: Double
    if let size = size {
      w = size.0
      h = size.1
    } else {
      var maxW: Double = 0
      var maxH: Double = 0
      for el in elements {
        if let el = el as? Element {
          if el.frame.size.width > maxW {
            maxW = el.frame.size.width
          }
          if el.frame.size.height > maxH {
            maxH = el.frame.size.height
          }
        }
      }
      w = maxW
      h = maxH
    }
    
    self.direction = direction
    self.distribution = distribution
    self.flowAlign = flowAlign
    self.padding = padding

    self.frame = Rect(x: 0, y: 0, width: w, height: h)
    self.flex = flex
    self.margin = margin
    self.align = align
    
    self.elements = elements
  }
}

public func flow(
  frame: Rect,
  direction: Direction,
  distribution: Distribution = .start,
  align: Alignment = .start,
  padding: Padding = Padding(),
  elements: [ElementType]
  ) {
  var totalFlex: Double = 0
  var totalFixed: Double = 0
  for element in elements {
    switch element {
    case let el as Double:
      totalFixed += el
    case let el as Flex:
      totalFlex += el.value
    case let el as Element:
      let margin = el.margin
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
  var elements2: [ElementType]
  if totalFlex > 0 || distribution == Distribution.spaceBetween || distribution == Distribution.spaceAround || distribution == Distribution.spaceAroundHalf {
    // layout with flex
    switch direction {
    case .horizontal:
      pos = padding.left
    case .vertical:
      pos = padding.top
    }
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
    case let el as Element:
      let margin = el.margin
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
            x: frame.origin.x + pos + margin.left,
            y: frame.origin.y + padding.top + margin.top - margin.bottom,
            width: width,
            height: el.frame.size.height
          )
        case .end:
          el.frame = Rect(
            x: frame.origin.x + pos + margin.left,
            y: frame.origin.y + frame.size.height - padding.bottom - el.frame.size.height - margin.bottom + margin.top,
            width: width,
            height: el.frame.size.height
          )
        case .center:
          el.frame = Rect(
            x: frame.origin.x + pos + margin.left,
            y: frame.origin.y + padding.top + margin.top - margin.bottom + (frame.size.height - padding.top - padding.bottom - el.frame.size.height)/2,
            width: width,
            height: el.frame.size.height
          )
        case .fill:
          el.frame = Rect(
            x: frame.origin.x + pos + margin.left,
            y: frame.origin.y + padding.top + margin.top - margin.bottom,
            width: width,
            height: frame.size.height - padding.top - padding.bottom
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
            x: frame.origin.x + padding.left + margin.left - margin.right,
            y: frame.origin.y + pos + margin.top,
            width: el.frame.size.width,
            height: height
          )
        case .end:
          el.frame = Rect(
            x: frame.origin.x + frame.size.width - padding.right - margin.right - el.frame.size.width + margin.left,
            y: frame.origin.y + pos + margin.top,
            width: el.frame.size.width,
            height: height
          )
        case .center:
          el.frame = Rect(
            x: frame.origin.x + padding.left + margin.left - margin.right + (frame.size.width - padding.left - padding.right - el.frame.size.height)/2,
            y: frame.origin.y + pos + margin.top,
            width: el.frame.size.width,
            height: height
          )
        case .fill:
          el.frame = Rect(
            x: frame.origin.x + padding.left + margin.left - margin.right,
            y: frame.origin.y + pos + margin.top,
            width: frame.size.width - padding.left - padding.right,
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
