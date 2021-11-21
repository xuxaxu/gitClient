//
//  animationView.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 21.11.2021.
//

import UIKit

class AnimationView: UIView {
    
    func createView(sizeOfSuper: CGRect){
        self.frame = CGRect(x: sizeOfSuper.width/2 - 25, y: sizeOfSuper.height/2 - 25, width: 50, height: 50)
        let imgView = UIImageView(image: UIImage(named: "Git"))
        imgView.frame = self.bounds
        self.addSubview(imgView)
        
        
        UIView.animate(withDuration: 1.0, delay:0, options: [.repeat, .autoreverse], animations: {
            self.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }) {_ in
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
        }
    
    func startInVC(vc: UIViewController) {
        self.createView(sizeOfSuper: vc.view.frame)
        vc.view.addSubview(self)
    }
    
    func removeFromVC() {
        self.removeFromSuperview()
    }

}
