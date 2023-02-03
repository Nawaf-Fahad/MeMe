//
//  DetailMemeViewController.swift
//  Meme
//
//  Created by Nawaf Alotaibi on 03/02/2023.
//

import UIKit

class DetailMemeViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var meme:Meme!
    override func viewDidLoad() {
        super.viewDidLoad()

        imgView.image = meme.memedImage
    }
    

    @IBAction func editButton(_ sender: Any) {
    }
    
}
