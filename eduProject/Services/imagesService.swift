//
//  imagesService.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 20.11.2021.
//

import Foundation
import UIKit

class ImagesService {
    var cache = NSCache<NSString, UIImage>()
    
    static let shared = ImagesService()
    
    private init () {}

    func getImage(url: String, completion: @escaping (UIImage?) -> Void )  {
        let nsUrl = NSString(string: url)
        if let img = cache.object(forKey: nsUrl) {
            completion(img)
        } else {
            DispatchQueue.global(qos: .background).async {
                    if let urlImg = URL.init(string: url),
                       let data = try? Data(contentsOf: urlImg),
                       let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.cache.setObject(image, forKey: nsUrl)
                                completion(image)
                            }
                        }
            }
        }
    }
}
