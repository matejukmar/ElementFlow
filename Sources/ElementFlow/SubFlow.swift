import Foundation

/**
 SubFlow element with its own collection of elements which can be included in a parent layout flow
 
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
public class SubFlow: Element {
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
  public var shift: Shift
  public var inset: Inset
  public var align: Alignment?
  
  
  var elements: [ElementType]
  
  public init(
    size: (Double, Double)? = nil,
    direction: Direction,
    distribution: Distribution = .start,
    flex: Double? = nil,
    flowAlign: Alignment = .start,
    padding: PaddingValue? = nil,
    shiftLeft: Double = 0,
    shiftUp: Double = 0,
    shiftRight: Double = 0,
    shiftDown: Double = 0,
    align: Alignment? = nil,
    inset: InsetValue = 0,
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
    
    var pLeft: Double = 0
    var pTop: Double = 0
    var pRight: Double = 0
    var pBottom: Double = 0
    switch padding {
    case let padding as Padding:
      pLeft = padding.left
      pTop = padding.top
      pRight = padding.right
      pBottom = padding.bottom
    case let padding as Double:
      pLeft = padding
      pTop = padding
      pRight = padding
      pBottom = padding
    default:
      break
    }
    self.padding = Padding(
      left: pLeft,
      top: pTop,
      right: pRight,
      bottom: pBottom
    )
    
    self.frame = Rect(x: 0, y: 0, width: w, height: h)
    self.flex = flex
    
    self.shift = Shift(
      left: shiftLeft,
      up: shiftUp,
      right: shiftRight,
      down: shiftDown
    )
    self.align = align
    
    switch inset {
    case let inset as Double:
      self.inset = Inset(inset)
    case let inset as Inset:
      self.inset = inset
    default:
      self.inset = Inset(0)
    }
    
    self.elements = elements
  }
}
