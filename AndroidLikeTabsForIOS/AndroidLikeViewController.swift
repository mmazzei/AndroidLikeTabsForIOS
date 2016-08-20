//
//  AndroidLikeViewController.swift
//  AndroidLikeTabsForIOS
//
//  Created by Matias Mazzei on 8/20/16.
//  Copyright © 2016 mmazzei. All rights reserved.
//

import UIKit

// The only place where this is needed is inside the "cycle" method.
// It's not difficult to use just the native animations there if you want
// to remove this dependency.
import IBAnimatable

/// This segue does nothing on perform. It shouldn't be executed.
/// It's only used to show the relationship from a AndroidLikeContainerViewController
/// to their childs in the storyboard.
class NoOpSegue: UIStoryboardSegue {
  override func perform() {
    // Do nothing
  }
}

private struct ChildViewControllerMetadata {
  let title: String
  let segueId: String
}

/// How to use:
/// - Subclass
/// - Use a NoOpSegue to link the controller to desired children
/// - At viewDidLoad call "addChild(segueId:title:)" for each child view controller.
/// - Avoid to add new segments once it's running, may broke temporarily the transition animations
class AndroidLikeViewController: AnimatableViewController {

  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var switchSegment: UnderlineSegmentedControl!

  private weak var currentChild: UIViewController?
  private var currentChildIndex = 0

  private var childrenMetadata: [ChildViewControllerMetadata] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    switchSegment.setSelectedSegmentIndex(0, animated: false)
  }

  func addChild(segueId id: String, title: String) {
    childrenMetadata.append(ChildViewControllerMetadata(title: title, segueId: id))
    switchSegment.appendSegment(title)
  }


  @IBAction func switchController() {
    performSegueWithIdentifier(childrenMetadata[switchSegment.selectedSegmentIndex].segueId, sender: nil)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let animationDir = currentChildIndex < switchSegment.selectedSegmentIndex ? TransitionDirection.Left : .Right
    currentChildIndex = switchSegment.selectedSegmentIndex

    let newChild = segue.destinationViewController
    addChild(newChild)
    cycle(from: currentChild, to: newChild, toDirection: animationDir)
  }

  /// Switch with an animated transition from "from" to "to" view controllers.
  private func cycle(from oldVC: UIViewController?, to newVC: UIViewController, toDirection transitionDirection: TransitionDirection = .Right) {
    // Other nice animation types:
    //animationType: .SystemPush(fromDirection: .Left/.Right),
    //animationType: .SystemMoveIn(fromDirection: .Left/.Right),

    let transitionContext = ContainerTransition(
      animationType: .Slide(toDirection: transitionDirection, params: []),
      container: containerView,
      parentViewController: self,
      fromViewController: oldVC,
      toViewController: newVC) {
        self.currentChild = newVC
    }
    transitionContext.transitionDuration = 0.5

    // Inside the transition it does the removing of the oldVC
    // and adding of the newVC!!! 😍
    transitionContext.animate()
  }



  // MARK: - Helpers

  /// Adds the view controller as a child
  /// The comment lines inside this method are an extract from the Apple Developer Doc.
  private func addChild(childVC: UIViewController) {
    // Call the addChildViewController: method of your container view controller.
    // This method tells UIKit that your container view controller is now managing
    //    the view of the child view controller.
    addChildViewController(childVC)

    // Add the child’s root view to your container’s view hierarchy.
    containerView.addSubview(childVC.view)

    // Always remember to set the size and position of the child’s frame as part of this process.
    // Add any constraints for managing the size and position of the child’s root view.
    childVC.view.translatesAutoresizingMaskIntoConstraints = false
    childVC.view.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor).active = true
    childVC.view.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
    childVC.view.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true

    // Call the didMoveToParentViewController: method of the child view controller.
    childVC.didMoveToParentViewController(self)
  }
}

