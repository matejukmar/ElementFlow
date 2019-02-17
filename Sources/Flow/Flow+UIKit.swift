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
    case let subFlow as Flow:
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
  public var margin: Margin
  public var align: Alignment?
  
  public init(
    _ view: UIView,
    size: (Double, Double)? = nil,
    flex: Double? = nil,
    margin: Double? = nil,
    marginLeft: Double? = nil,
    marginTop: Double? = nil,
    marginRight: Double? = nil,
    marginBottom: Double? = nil,
    marginHorizontal: Double? = nil,
    marginVertical: Double? = nil,
    align: Alignment? = nil
  ) {
    self.view = view
    if let (width, height) = size {
      self.frame = Rect(
        x: Double(view.frame.origin.x),
        y: Double(view.frame.origin.y),
        width: Double(width),
        height: Double(height)
      )
      view.frame = self.frame.cgRect
    } else {
      self.frame = Rect(
        x: Double(view.frame.origin.x),
        y: Double(view.frame.origin.y),
        width: Double(view.frame.size.width),
        height: Double(view.frame.size.height)
      )
    }
    
    self.flex = flex
    self.margin = Margin(
      left: marginHorizontal ?? marginLeft ?? margin ?? 0,
      top: marginVertical ?? marginTop ?? margin ?? 0,
      right: marginHorizontal ?? marginRight ?? margin ?? 0,
      bottom: marginVertical ?? marginBottom ?? margin ?? 0
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
