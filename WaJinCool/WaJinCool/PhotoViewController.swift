//
//  PhotoViewController.swift
//  WaJinCool
//
//  Created by Willy Wu on 2017/9/18.
//  Copyright © 2017年 Willy Wu. All rights reserved.
//

import UIKit
import Photos

protocol PhotoViewControllerDelegate {
    func didGetPhoto(photo: UIImage, assetId: String)
}

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var delegate: PhotoViewControllerDelegate! = nil
    var assetId = ""
    var record: Record?
    var photoImage: UIImage?
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let photoImage = photoImage {
            self.photo.image = photoImage
            doneButton.isEnabled = true
        } else {
            if let record = record {
                if record.hasPhoto {
                    self.photo.image = record.photo
                    doneButton.isEnabled = true
                } else {
                    doneButton.isEnabled = false
                }
            } else {
                doneButton.isEnabled = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        type = "PhotoLibrary"
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        if type == "Camera" {
            NSLog("Camera")
            var imageData = UIImageJPEGRepresentation(selectedImage, 0.6)
            var compressedJPGImage = UIImage(data: imageData!)
            UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
            
            //UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, #selector(cameraImageSavedAsynchronously), nil)
            UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)


            /*
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 1
            
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            NSLog("fetchResult \(fetchResult) llll \(fetchResult.firstObject)")
            if (fetchResult.firstObject != nil)
            {
                let lastImageAsset: PHAsset = fetchResult.firstObject as! PHAsset
                assetId = lastImageAsset.value(forKey: "localIdentifier")! as! String
                NSLog("AAAA \(assetId)")
            }
*/
        } else {
            NSLog("AAAAAAAAAA")
            if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {
                let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                let asset = result.firstObject
                assetId = asset?.value(forKey: "localIdentifier")! as! String
                NSLog("BBBBBB \(assetId)")
            }
        }
        
        // Set photoImageView to display the selected image.
        photo.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
        
        doneButton.isEnabled = true
    }
    
    @IBAction func clickDone(_ sender: UIBarButtonItem) {
        delegate.didGetPhoto(photo: photo.image!, assetId: assetId)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            type = "Camera"
            
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if error == nil {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 1
            
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            if (fetchResult.firstObject != nil) {
                let lastImageAsset: PHAsset = fetchResult.firstObject!
                assetId = lastImageAsset.value(forKey: "localIdentifier")! as! String
            }

            let ac = UIAlertController(title: "Saved!", message: "Image saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
}
