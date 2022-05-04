//
//  UserImageView.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-18.
//

import UIKit

import UIKit

// create caching list with key <AnyObject type>, and value <UIImage type>
let userImageCache = NSCache<AnyObject, UIImage>()

class UserImageView: UIImageView {
    
    // task for session data task to carry out
    var task: URLSessionDataTask!
    
    func loadImage(from url: URL) {
        // clear image to prevent slow loading image replacing
        image = nil
        
        // check if task exists in order to cancel the task
        // NOTE: cannot cancel a task on first go around - check necessary
        if let task = task {
            task.cancel()
        }
        
        // check if the image for the user has been stored in the cache
        // get the image and store it in the imageView
        if let userImageFromCache = userImageCache.object(forKey: url.absoluteString as AnyObject) {
            self.image = userImageFromCache
            return
        }
        
        // image doesn't exist in cache
        task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // get the image from url
            guard let data = data, let userImage = UIImage(data: data) else {
                print("Failed to load image form URL : \(url)")
                return
            }
            
            // set the user image cache with the uiimage recieved
            userImageCache.setObject(userImage, forKey: url.absoluteString as AnyObject)
            
            // make sure to use the main thread to add the image
            DispatchQueue.main.async {
                // in the main thread, add the image to the imageview
                self.image = userImage
            }
        }
        task.resume()
    }
}
