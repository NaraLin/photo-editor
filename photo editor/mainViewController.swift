//
//  mainViewController.swift
//  photo editor
//
//  Created by 林靖芳 on 2024/5/16.
//

import UIKit

class mainViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func photoAction(sourceType:UIImagePickerController.SourceType){
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        present(controller, animated: true)
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
        let alertController = UIAlertController(title: "select photo", message: "", preferredStyle: .actionSheet)
        let selectActions = [source(title: "從相簿選取", photoSource: .photoLibrary), source(title: "拍照", photoSource: .camera)]
        
        for i in selectActions{
            let action = UIAlertAction(title: i.title, style: .default) { action in
                self.photoAction(sourceType: i.photoSource)
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { action in
            self.dismiss(animated: true)
        })
                                  
        )
        
        present(alertController, animated: true)
        
        
    }
}
                                
   
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        


extension mainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        
        let editViewController = storyboard?.instantiateViewController(identifier: "\(EditViewController.self)", creator: { coder in
            EditViewController.init(coder: coder, image: image!)
        })
        
        dismiss(animated: true)
        
        if let editViewController{
            show(editViewController, sender: nil)
        }
        
       
    }
    
}

    
