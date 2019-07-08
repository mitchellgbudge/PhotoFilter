//
//  ViewController.swift
//  PhotoFilter
//
//  Created by Mitchell Budge on 7/8/19.
//  Copyright © 2019 Mitchell Budge. All rights reserved.
//

import UIKit
import Photos

class PhotoViewController: UIViewController {

    // MARK: - Methods & Actions
    
    func updateImage() {
        if let originalImage = originalImage {
            imageView.image = image(byFiltering: originalImage)
        } else {
            imageView.image = nil
        }
    }
    
    private func image(byFiltering image: UIImage) -> UIImage {
        guard let cgImage = originalImage?.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        filter?.setValue(ciImage, forKey: "inputImage")
        filter?.setValue(saturationSlider.value, forKey: "inputSaturation")
        filter?.setValue(brightnessSlider.value, forKey: "inputBrightness")
        filter?.setValue(contrastSlider.value, forKey: "inputContrast")
        guard let outputCIImage = filter?.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        return UIImage(cgImage: outputCGImage)
    }
    
    @IBAction func choosePhotoButtonPressed(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            NSLog("The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func savePhotoButtonPressed(_ sender: Any) {
        guard let originalImage = originalImage else { return }
        let processedImage = image(byFiltering: originalImage)
        PHPhotoLibrary.requestAuthorization { (status) in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAsset(from: processedImage)
            }, completionHandler: { (success, error) in
                if let error = error {
                    NSLog("Error saving photo: \(error)")
                    return
                }
                NSLog("Saved photo!")
            })
        }
    }
    
    @IBAction func brightnessValueChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func contrastValueChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func saturationValueChanged(_ sender: Any) {
        updateImage()
    }
    
    
    // MARK: - Outlets & Properties
    
    var originalImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    private let filter = CIFilter(name: "CIColorControls")
    private let context = CIContext(options: nil)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    
}

extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
