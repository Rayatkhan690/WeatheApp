//
//  HomeViewController.swift
//  Breeze Bliss
//
//  Created by Rayat Khan on 29/11/2023.
//  Copyright © 2023 Bogdan Ponocko. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var btnGetStarted: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnGetStarted.layer.cornerRadius = 12
        btnGetStarted.layer.masksToBounds = true
    }
    
    @IBAction func btnGetStartedAction(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        navigationController?.pushViewController(vc, animated: true)
    }

}
