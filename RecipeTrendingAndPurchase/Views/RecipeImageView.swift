//
//  RecipeImageView.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-18.
//

import UIKit

// create caching list with key <AnyObject type>, and value <UIImage type>
let recipeImageCache = NSCache<AnyObject, UIImage>()

class RecipeImageView: UIImageView {
    
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
        
        // check if the image for the recipe has been stored in the cache
        // get the image and store it in the imageView
        if let recipeImageFromCache = recipeImageCache.object(forKey: url.absoluteString as AnyObject) {
            self.image = recipeImageFromCache
            return
        }
        
        // image doesn't exist in cache
        task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // get the image from url
            guard let data = data, let recipeImage = UIImage(data: data) else {
                print("Failed to load image form URL : \(url)")
                return
            }
            
            // set the recipe image cache with the uiimage recieved
            recipeImageCache.setObject(recipeImage, forKey: url.absoluteString as AnyObject)
            
            // make sure to use the main thread to add the image
            DispatchQueue.main.async {
                // in the main thread, add the image to the imageview
                self.image = recipeImage
            }
        }
        task.resume()
    }

}
