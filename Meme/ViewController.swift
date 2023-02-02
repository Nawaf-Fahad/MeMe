//
//  ViewController.swift
//  Meme
//
//  Created by Nawaf Alotaibi on 01/02/2023.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate{
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "impact", size: 40)!,
        NSAttributedString.Key.strokeWidth : -1.0
           ]
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    
    @IBOutlet weak var share: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var Camera: UIBarButtonItem!
    @IBOutlet weak var Cancel: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        topTextField.placeholder = "TOP"
        topTextField.textAlignment = .center
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.placeholder = "BOTTOM"
        bottomTextField.textAlignment = .center
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Camera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func save(memedImage: UIImage) {
        let meme = Meme(topText: topTextField.text! as NSString?, bottomText: bottomTextField.text! as NSString?,  image: imagePickerView.image, memedImage: memedImage)
        
    }
    func generateMemedImage() -> UIImage {
            
        SwitchVis(hidden: true)
            
            // render view to an image
            UIGraphicsBeginImageContext(self.view.frame.size)
            self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
            let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
        SwitchVis(hidden: false)
            
            return memedImage
        }
    
    func SwitchVis(hidden: Bool) {

            navBar.isHidden = hidden
            toolbar.isHidden = hidden
        }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            
            //Erase the default text when editing
            if textField == topTextField && textField.text == "TOP" {
                textField.text = ""
            } else if textField == bottomTextField && textField.text == "BOTTOM" {
                textField.text = ""
            }
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Allows the user to use the return key to hide keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func unsubscribeFromKeyboardNotifications() {
         
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
     }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
          //getting height of keyboard for setting view's frame accordingly
          let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
          return keyboardSize.cgRectValue.height
      }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if bottomTextField.isFirstResponder{
            view.frame.origin.y -= getKeyboardHeight(notification: notification)
        }
        
    }

    
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    

  


    @IBAction func pickAnImage(_ sender: Any) {
        let imagePickerView = UIImagePickerController()
        imagePickerView.delegate = self
        imagePickerView.sourceType = .photoLibrary
                present(imagePickerView, animated: true, completion: nil)
            }
    
    
    
    @IBAction func pickAnImageFromCamera(_ sender: UIBarButtonItem) {
        let imagePickerView = UIImagePickerController()
        imagePickerView.delegate = self
        imagePickerView.sourceType = .camera
                present(imagePickerView, animated: true, completion: nil)
            }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .scaleAspectFit
            share.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func activityVC(_ sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let shareController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        present(shareController, animated: true, completion: nil)
        shareController.completionWithItemsHandler = {activity, completed, items, error -> Void in
            if completed{
                self.save(memedImage: memedImage)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    
    @IBAction func Cancel(_ sender: UIBarButtonItem) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
        share.isEnabled = false
    }
    
}

