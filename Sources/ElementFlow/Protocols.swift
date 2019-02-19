import Foundation

public protocol ElementType {}

public protocol Element: class, ElementType {
  var frame: Rect { get set }
  var flex: Double?  { get set }
  var shift: Shift  { get set }
  var inset: Inset  { get set }
  var align: Alignment?  { get set }
}

extension Double: ElementType {}
extension Flex: ElementType {}

public protocol PaddingValue {}
extension Double: PaddingValue {}
extension Padding: PaddingValue {}

public protocol InsetValue {}
extension Double: InsetValue {}
extension Inset: InsetValue {}
