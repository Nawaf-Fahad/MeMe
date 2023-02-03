//
//  ViewController.swift
//  Meme
//
//  Created by Nawaf Alotaibi on 01/02/2023.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate,UITextFieldDelegate{
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "impact", size: 40)!,
        NSAttributedString.Key.strokeWidth : -3.5
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
        setTextFieldAttributes(textField: topTextField, text: "TOP")
        setTextFieldAttributes(textField: bottomTextField, text: "BOTTOM")
    }
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
        Camera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        if imagePickerView.image == nil
        {share.isEnabled = false}
        else{
            share.isEnabled = true
        }
        
        #if targetEnvironment(simulator)
            Camera.isEnabled = false;
        #else
            Camera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera);
        #endif
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setTextFieldAttributes(textField: UITextField, text: String)
    {
        textField.delegate = self
        textField.text = text
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
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
    
    
    
    
    func ImagePickerSourceType(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        ImagePickerSourceType(sourceType: .photoLibrary)
    }
    
    
    
    @IBAction func pickAnImageFromCamera(_ sender: UIBarButtonItem) {
        ImagePickerSourceType(sourceType: .camera)
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imagePickerView.image = image
            
            share.isEnabled = true
            
            view.layoutIfNeeded()
            
            dismiss(animated: true, completion: nil)            }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func activityVC(_ sender: Any) {
        let memedImage = generateMemedImage()
        
        let shareActivityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        shareActivityViewController.completionWithItemsHandler = { activity, completed, items, error in
            
            if completed {
                
                //save the image
                self.save(memedImage: memedImage)
                
                //Dismiss the shareActivityViewController
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
        present(shareActivityViewController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func Cancel(_ sender: Any) {
        topTextField.text = ""
        bottomTextField.text = ""
        imagePickerView.image = nil
        share.isEnabled = false
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
    }
    
    
    func save(memedImage: UIImage) {
        let memeImage = generateMemedImage()
        //Create the meme
        var meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, image: imagePickerView.image, memedImage: memeImage)
        
    }
    func generateMemedImage() -> UIImage {
        
        SwitchVis(hidden: true)
        
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memeImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        SwitchVis(hidden: false)
        
        return memeImage
    }
    
    func SwitchVis(hidden: Bool) {
        
        navBar.isHidden = hidden
        toolbar.isHidden = hidden
    }
    
    
}

