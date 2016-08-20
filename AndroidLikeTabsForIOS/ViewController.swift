//
//  ViewController.swift
//  AndroidLikeTabsForIOS
//
//  Created by Matias Mazzei on 8/20/16.
//  Copyright © 2016 mmazzei. All rights reserved.
//

import UIKit

class ViewController:  AndroidLikeViewController {
  override func viewDidLoad() {
    addChild(segueId: "FirstSegue", title: "FIRST")
    addChild(segueId: "SecondSegue", title: "SECOND")
    addChild(segueId: "ThirdSegue", title: "THIRD")

    super.viewDidLoad()
  }
}