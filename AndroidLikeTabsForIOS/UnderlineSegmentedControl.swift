//
//  UnderlineSegmentedControl.swift
//  AndroidLikeTabsForIOS
//
//  Created by Matias Mazzei on 8/20/16.
//  Copyright © 2016 mmazzei. All rights reserved.
//

import UIKit

/// Draws a control similar to UISegmentedControl, but the
/// selected segment is highlighted with a coloured underline.
///
/// The API wants to behave like the standard UISegmentedControl,
/// however it may be simpler.
///
@IBDesignable
class UnderlineSegmentedControl: UIControl {
  private let elements: UIStackView = UIStackView()

  private let underline: UIView = UIView()
  private var underlineLeftConstraint: NSLayoutConstraint!
  private var underlineWidthConstraint: NSLayoutConstraint!
  private let underlineHeight: CGFloat = CGFloat(3)


  // MARK: - Visible properties

  @IBInspectable var textFont: UIFont! = UIFont.systemFontOfSize(UIFont.buttonFontSize()) {
    didSet {
      elements.arrangedSubviews.forEach {
        ($0 as! UIButton).titleLabel?.font = textFont
      }
      setNeedsDisplay()
    }
  }

  @IBInspectable var underlineColor: UIColor = UIColor.greenColor() {
    didSet {
      underline.backgroundColor = underlineColor
      setNeedsDisplay()
    }
  }

  private (set) var selectedSegmentIndex = UISegmentedControlNoSegment {
    didSet {
      guard oldValue != selectedSegmentIndex else { return }
      sendActionsForControlEvents(.ValueChanged)
    }
  }

  var numberOfSegments: Int {
    return elements.subviews.count
  }


  // MARK: - Set Up

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setUp()
  }

  private func setUp() {
    elements.axis = .Horizontal
    elements.distribution = .FillEqually
    elements.alignment = .Fill
    elements.translatesAutoresizingMaskIntoConstraints = false
    addSubview(elements)

    elements.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
    elements.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
    elements.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
    elements.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true


    underline.translatesAutoresizingMaskIntoConstraints = false
    addSubview(underline)

    underline.backgroundColor = UIColor.greenColor()
    underline.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
    underline.heightAnchor.constraintEqualToConstant(underlineHeight).active = true

    underlineLeftConstraint = underline.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor)
    underlineWidthConstraint = underline.widthAnchor.constraintEqualToConstant(0)
    addConstraint(underlineLeftConstraint)
    addConstraint(underlineWidthConstraint)
  }

  override func prepareForInterfaceBuilder() {
    appendSegment("One")
    appendSegment("Two")
    appendSegment("Three")
    selectedSegmentIndex = 0
  }


  // MARK: - API

  /// Add a new segment with the given title
  func appendSegment(title: String) {
    let button = UIButton(type: .Custom)
    button.setTitle(title, forState: .Normal)
    button.addTarget(self, action: #selector(didSelectSegment(_:)), forControlEvents: .TouchUpInside)
    button.tag = elements.subviews.count
    button.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)

    button.setTitleColor(tintColor, forState: .Normal)
    button.backgroundColor = backgroundColor
    button.titleLabel?.font = textFont


    elements.addArrangedSubview(button)
    setNeedsLayout()
  }

  /// Remove the last segment of this segment control and returns the title
  func removeLastSegment() -> String? {
    guard !elements.arrangedSubviews.isEmpty else { return nil }

    let lastButton = elements.arrangedSubviews.last! as! UIButton
    lastButton.removeFromSuperview()
    setNeedsLayout()

    return lastButton.currentTitle
  }

  override func intrinsicContentSize() -> CGSize {
    return elements.intrinsicContentSize()
  }

  func setSelectedSegmentIndex(index: Int, animated: Bool) {
    selectedSegmentIndex = index
    selectElement(index, animated: animated)
    setNeedsDisplay()
  }


  // MARK: - Private API

  func didSelectSegment(sender: UIButton) {
    setSelectedSegmentIndex(sender.tag, animated: true)
  }

  private func selectElement(index: Int, animated: Bool = true) {
    let selectedElement = elements.arrangedSubviews[index]

    removeConstraint(underlineLeftConstraint)
    underlineLeftConstraint = underline.leftAnchor
      .constraintEqualToAnchor(selectedElement.leftAnchor)
    addConstraint(underlineLeftConstraint)

    removeConstraint(underlineWidthConstraint)
    underlineWidthConstraint = underline.widthAnchor
      .constraintEqualToAnchor(selectedElement.widthAnchor)
    addConstraint(underlineWidthConstraint)

    let animations = { self.layoutIfNeeded() }

    if animated {
      UIView.animateWithDuration(0.6, animations: animations)
    }
    else {
      animations()
    }
  }
}