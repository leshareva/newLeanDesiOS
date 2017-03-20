import UIKit
import Firebase
import DigitsKit
import DKImagePickerController
import Alamofire
import Cosmos

extension ConceptViewController {
    
    func closeView() {
        guard let taskId = task!.taskId else {
            return
        }
        dismiss(animated: true, completion: nil)
//        let ref = FIRDatabase.database().reference().child("tasks").child(taskId)
//        
//        ref.observeSingleEvent(of: .value, with: {(snapshot) in
//            if let status = (snapshot.value as! NSDictionary)["status"] as? String {
//                var stage = ""
//                if status == "conceptApprove" {
//                    stage = "concept"
//                } else if status == "designApprove" {
//                    stage = "design"
//                }
//                
//                let values : [String: AnyObject] = ["status" : "discuss" as AnyObject]
//                ref.child(stage).updateChildValues(values, withCompletionBlock: { (err, ref) in
//                    if err != nil {
//                        print(err!)
//                        return
//                    }
//                })
//
//                
//                
//            }
//            
//        }, withCancel: nil)
    }

    
    func showSuccessAlertView(status: String, time: Int, price: Int) {
        guard let taskId = task!.taskId else {
            return
        }
        
        if status == "conceptApprove" {
            let alert = UIAlertController(title: "Подтвердите", message: "После принятия черновика, вы не сможете вносить изменения в концепцию макета", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Подтверждаю", style: .default, handler: { (action: UIAlertAction!) in
                self.navigationController?.popToRootViewController(animated: true)
                self.sendBill(taskId: taskId, message: "Клиент утвердил черновик")
            }))
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        } else if status == "designApprove" {
                        
            let alert = UIAlertController(title: "Подтвердите", message: "После принятия чистовика вы не сможете вносить в него корректировки. Дизайнер будет готовить исходники.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Подтверждаю", style: .default, handler: { (action: UIAlertAction!) in
                self.navigationController?.popToRootViewController(animated: true)
                self.sendBill(taskId: taskId, message: "Клиент утвердил чистовик")
                
            }))
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    func sendBill(taskId: String, message: String) {
        
        guard let designerId = task?.toId else {
            return
        }
        
        let parameters: Parameters = [
            "taskId": taskId
        ]
        
        Alamofire.request("\(Server.serverUrl)/workdone",
            method: .post,
            parameters: parameters)
        
        TaskMethods.sendPush(message: message, toId: designerId, taskId: taskId)
        
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    func showShareButtons(_ tapGesture: MyTapGesture) {        
        guard let image = tapGesture.anyobj?["image"] as? UIImage else {
            return
        }
        
        let alertController = UIAlertController(title: "Поделиться файлом", message: "Сохраните изображение в альбом", preferredStyle: .actionSheet)
        
        let sendButton = UIAlertAction(title: "Сохранить в альбом", style: .default, handler: { (action) -> Void in
            UIImageWriteToSavedPhotosAlbum(image, self,  #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        })
        
        
        let cancelButton = UIAlertAction(title: "Отмена", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        
        alertController.addAction(sendButton)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    
}
