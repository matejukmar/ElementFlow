import Foundation

/**
 Layouts elements in a frame
 
 - frame: layout enclosing frame
 - direction: main layout direction, it can be `.horizontal` or `.vertical`
 - distribution: distribution of elements along main layout direction. Possible of values `Distribution` enum are:
  * `.start` alignes elements to the left of horizontal or top of vertical direction
  * `.end` alignes elements to the right of horizontal or bottom of vertical direction
  * `.center` alignes elements to the center of the main direction
  * `.spaceBetween` distributes element along the main direction with equal spacings between them
  * `.spaceAround` distributes element along the main direction with equal spacings between them and around them
  * `.spaceAroundHalf` distributes element along the main direction with equal spacings between them and half the spacing around them
 - align: aligns elements in secondary perpendicular to main direction. Possible values of `Alignment` are:
  * `.start` aligns elements to start of secondary direction (left or top)
  * `.end` aligns elements to end of secondary direction (right or bottom)
  * `.center` aligns elements to the center of secondary direction
  * `.fit` fits and resizes the element to the full extent of the secondary direction limited within the parent padding
  * `.extend` fits and resizes the element to the full extent of the secondary direction ignoring and not limited to the parent padding
 - padding: specifies the padding edge of the layout frame. The value can be single `Double` number which sets equal padding on all sides of a frame or `Padding` struct which allows to set different paddings on different sides.
 - elements: array of elements to layout in a frame
*/
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
      if let flex = el.flex {
        totalFlex += flex
      } else {
        switch direction {
        case .horizontal:
          totalFixed += el.frame.size.width
        case .vertical:
          totalFixed += el.frame.size.height
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
      let shift = el.shift
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
            x: frame.origin.x + pos - shift.left + shift.right,
            y: frame.origin.y + padding.top - shift.up + shift.down,
            width: width,
            height: el.frame.size.height
          )
        case .end:
          el.frame = Rect(
            x: frame.origin.x + pos - shift.left + shift.right,
            y: frame.origin.y + frame.size.height - padding.bottom - el.frame.size.height - shift.up + shift.down,
            width: width,
            height: el.frame.size.height
          )
        case .center:
          el.frame = Rect(
            x: frame.origin.x + pos - shift.left + shift.right,
            y: frame.origin.y + padding.top - shift.up + shift.down + (frame.size.height - padding.top - padding.bottom - el.frame.size.height)/2,
            width: width,
            height: el.frame.size.height
          )
        case .fit:
          let inset = el.inset;
          el.frame = Rect(
            x: frame.origin.x + pos - shift.left + shift.right,
            y: frame.origin.y + padding.top + inset.start - shift.up + shift.down,
            width: width,
            height: frame.size.height - padding.top - padding.bottom - inset.start - inset.end
          )
        case .extend:
          let inset = el.inset;
          el.frame = Rect(
            x: frame.origin.x + pos - shift.left + shift.right,
            y: frame.origin.y + inset.start - shift.up + shift.down,
            width: width,
            height: frame.size.height - inset.start - inset.end
          )
        }

        pos += width
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
            x: frame.origin.x + padding.left - shift.left + shift.right,
            y: frame.origin.y + pos - shift.up + shift.down,
            width: el.frame.size.width,
            height: height
          )
        case .end:
          el.frame = Rect(
            x: frame.origin.x + frame.size.width - padding.right - el.frame.size.width - shift.left + shift.right,
            y: frame.origin.y + pos - shift.up + shift.down,
            width: el.frame.size.width,
            height: height
          )
        case .center:
          el.frame = Rect(
            x: frame.origin.x + padding.left - shift.left + shift.right + (frame.size.width - padding.left - padding.right - el.frame.size.height)/2,
            y: frame.origin.y + pos - shift.up + shift.down,
            width: el.frame.size.width,
            height: height
          )
        case .fit:
          let inset = el.inset;
          el.frame = Rect(
            x: frame.origin.x + padding.left - shift.left + shift.right + inset.start,
            y: frame.origin.y + pos - shift.up + shift.down,
            width: frame.size.width - padding.left - padding.right - inset.start - inset.end,
            height: height
          )
        case .extend:
          let inset = el.inset;
          el.frame = Rect(
            x: frame.origin.x - shift.left + shift.right + inset.start,
            y: frame.origin.y + pos - shift.up + shift.down,
            width: frame.size.width - inset.start - inset.end,
            height: height
          )

        }
        pos += height
      }
    default:
      fatalError("not supported")
    }
  }
}
