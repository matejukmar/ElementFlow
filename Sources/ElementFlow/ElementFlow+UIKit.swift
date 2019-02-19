#if canImport(UIKit)

import Foundation
import UIKit

public func flow(in view: UIView,
  direction: Direction,
  distribution: Distribution = .start,
  align: Alignment = .start,
  padding: Padding = Padding(),
  elements: [ElementType]
  ) {
  add(elements: elements, to: view)
  flow(
    frame: view.frame.flowRect,
    direction: direction,
    distribution: distribution,
    align: align,
    padding: padding,
    elements: elements
  )
}

func add(elements: [ElementType], to view: UIView) {
  for element in elements {
    switch element {
    case let subView as View:
      if subView.view.superview != view {
        view.addSubview(subView.view)
      }
    case let subFlow as SubFlow:
      add(elements: subFlow.elements, to: view)
    default:
      break;
    }
  }
}

public class View: Element {
  public var view: UIView
  public var frame: Rect {
    didSet {
      print("I have changed frame", frame)
      view.frame = self.frame.cgRect
    }
  }
  public var flex: Double?
  public var inset: Inset
  public var shift: Shift
  public var align: Alignment?
  
  public init(
    _ view: UIView,
    width: Double? = nil,
    height: Double? = nil,
    flex: Double? = nil,
    shiftLeft: Double = 0,
    shiftUp: Double = 0,
    shiftRight: Double = 0,
    shiftDown: Double = 0,
    align: Alignment? = nil,
    inset: InsetValue = 0
  ) {
    self.view = view
    self.frame = Rect(
      x: Double(view.frame.origin.x),
      y: Double(view.frame.origin.y),
      width: width ?? Double(view.frame.size.width),
      height: height ?? Double(view.frame.size.height)
    )
    
    self.flex = flex

    switch inset {
    case let inset as Double:
      self.inset = Inset(inset)
    case let inset as Inset:
      self.inset = inset
    default:
      self.inset = Inset(0)
    }
    
    self.shift = Shift(
      left: shiftLeft,
      up: shiftUp,
      right: shiftRight,
      down: shiftDown
    )
    self.align = align
  }
}

public extension CGRect {
  public var flowRect: Rect {
    return Rect(x: Double(origin.x), y: Double(origin.y), width: Double(size.width), height: Double(size.height))
  }
}

public extension Rect {
  public var cgRect: CGRect {
    return CGRect(x: CGFloat(origin.x), y: CGFloat(origin.y), width: CGFloat(size.width), height: CGFloat(size.height))
  }
}

#endif
