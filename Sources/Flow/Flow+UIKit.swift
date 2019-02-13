#if canImport(UIKit)
import Foundation
import UIKit

public class UIFlow: Flow {
  public var view: UIView
  public var frame: Rect {
    didSet {
      print("I have changed frame", frame)
      view.frame = self.frame.cgRect
    }
  }
  public var flex: Double?
  public var margin: Margin?
  public var align: Alignment?
  
  public init(view: UIView, frame: CGRect? = nil, flex: Double? = nil, margin: Margin? = nil, align: Alignment? = nil) {
    self.view = view
    if let frame2 = frame {
      view.frame = frame2
      self.frame = Rect(
        x: Double(frame2.origin.x),
        y: Double(frame2.origin.y),
        width: Double(frame2.size.width),
        height: Double(frame2.size.height)
      )
    } else {
      self.frame = Rect(
        x: Double(view.frame.origin.x),
        y: Double(view.frame.origin.y),
        width: Double(view.frame.size.width),
        height: Double(view.frame.size.height)
      )
    }
    self.flex = flex
    self.margin = margin
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
