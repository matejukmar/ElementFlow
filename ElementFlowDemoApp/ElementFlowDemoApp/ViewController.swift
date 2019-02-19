//
//  ViewController.swift
//  FlowApp
//
//  Created by Matej Ukmar on 10/02/2019.
//  Copyright © 2019 ZEN+. All rights reserved.
//

import UIKit
import ElementFlow

class ViewController: UIViewController {
  
  let v1 = UIView()
  let v2 = UIView()
  
  let v3 = UIView()
  let v4 = UIView()
  let v5 = UIView()
  let v6 = UIView()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    v1.backgroundColor = UIColor.orange
    v2.backgroundColor = UIColor.blue
    v3.backgroundColor = UIColor.red
    v4.backgroundColor = UIColor.yellow
    //    v5.backgroundColor = UIColor.green
    //    v6.backgroundColor = UIColor.purple
  }
  
  override func viewDidLayoutSubviews() {
    print("I'm laying subs");
    
    flow(
      in: self.view!,
      direction:    .vertical,
      align:        .fit,
      elements: [
        88, //fixed
        View(v1, height: 100),
        View(v2, flex: 1, inset: 25),
        View(v3, flex: 1),
        View(v4, flex: 1),
        64
      ]
    )
    
    
    //    flow(
    //      in: self.view!,
    //      direction:    .vertical,
    //      align:        .fit,
    //      padding:       Padding(horizontal: 25),
    //
    //      elements: [
    //        88, //fixed
    //        View(v1, flex: 1),
    //        View(v2, flex: 1, align: .extend),
    //        View(v3, flex: 1),
    //        View(v4, flex: 1),
    //        64
    //      ]
    //    )
    
    
    //    flow(
    //      in: self.view!,
    //      direction:    .vertical,
    //      align:        .center,
    //      padding:       Padding(horizontal: 25),
    //
    //      elements: [
    //        88, //fixed
    //        View(v1, size: (50, 50)),
    //        Flex(1),
    //        Flow(
    //          direction:    .vertical,
    //          distribution: .spaceAround,
    //          flowAlign:    .fill,
    //          flex:         1.5,
    //          align:        .fill,
    //
    //          elements: [
    //            View(v3, size: (50, 50)),
    //            View(v4, size: (50, 50), marginTop: 5.0),
    //            View(v5, size: (50, 50), marginBottom: 5.0),
    //            View(v6, size: (50, 50))
    //          ]
    //        ),
    //        Flex(1),
    //        View(v2, size: (50, 50)),
    //        64
    //      ]
    //    )
  }
}



