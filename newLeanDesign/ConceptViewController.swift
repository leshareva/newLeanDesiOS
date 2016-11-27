//
//  ConceptViewController.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 9/15/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints
import Firebase
import Alamofire
import DigitsKit

class ConceptViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    let ref = FIRDatabase.database().reference()
    let customCellIdentifier = "customCellIdentifier"
 
    
    let buttonView = ButtonView()
    
    var task: Task? {
        didSet {
          
        }
    }
    
    var concepts = [Concept]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(CustomCell.self, forCellWithReuseIdentifier: customCellIdentifier)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Обсудить", style: .plain, target: self, action: #selector(closeView))
        
        self.buttonView.acceptTaskButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleApproveView)))
        
    }
    
    
    func closeView() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupView() {
  
        self.view.addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(buttonView.widthAnchor == self.view.widthAnchor,
                                 buttonView.bottomAnchor == self.view.bottomAnchor,
                                 buttonView.heightAnchor == 50)
        buttonView.acceptTaskButtonView.backgroundColor = UIColor(r: 109, g: 199, b: 82)
        buttonView.buttonLabel.text = "Согласовать"
    }
    

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    

    var day = 0;
    var dayname = ["день", "дня", "дней"]

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! CustomCell
        
      
        let concept = concepts[indexPath.item]
        
        if let imageUrl = concept.imgUrl {
            
            cell.imageView.loadImageUsingCashWithUrlString(imageUrl)
            
            cell.textView.isHidden = true
            cell.priceLabel.isHidden = true
            cell.timeLabel.isHidden = true
            cell.descriptView.isHidden = true
//            cell.imageWidthAnchor?.constant = s
            
        } else if let text = concept.text {
 
            cell.imageView.isHidden = true
            cell.textView.isHidden = false
            cell.priceLabel.isHidden = false
            cell.descriptView.isHidden = false
            cell.textView.text = text

            buttonView.buttonLabel.text = "Все верно!"

        }
        return cell
    }
    
    
    
    func checkNumberOfDays(_ number: Int) -> Int {
        let b = number % 10
        let a = (number % 100 - b) / 10
        if (a == 0 || a > 2) {
            if (b == 0 || (b > 4 && b <= 9)) {
                day = 2
            } else if (b != 1) {
                day = 1
            } else { day = 0 }
        } else { day = 2 }
        return day
    }
    
   
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return concepts.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 280
        
        let concept = concepts[indexPath.item]
        let width = UIScreen.main.bounds.width
        let screenWidth: CGFloat = view.frame.width
        
        if concept.imgUrl != nil {
            if let imageWidth = concept.imageWidth?.floatValue, let imageHeight = concept.imageHeight?.floatValue {
                //h1 / w1 = h2 / w2
                //solve for h1
                //h1 = h2 / w2 * w1
                height = CGFloat(imageHeight / imageWidth * Float(screenWidth))
            }
        } else if concept.text != nil {
            height = view.frame.height
        }
        
        return CGSize(width: width, height: height)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    
    
    
    
    
    func handleApproveView() {
        
        
        if let taskId = task!.taskId {
            let taskRef:FIRDatabaseReference    = ref.child("tasks").child(taskId)
            let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
            let value: [String: AnyObject] = ["approveTime": timestamp]
            taskRef.child("awareness").updateChildValues(value, withCompletionBlock: { (err, ref) in
                if err != nil {
                   print(err as! NSError)
                    return
                }
            })
            
            taskRef.observeSingleEvent(of: .value, with: { (snapshot:FIRDataSnapshot) in
                var time : Int?
                let status = (snapshot.value as? NSDictionary)!["status"] as? String
                time =  (snapshot.value as? NSDictionary)!["time"] as? Int
                if let price = (snapshot.value as? NSDictionary)!["price"] as? Int {
                    
                    if let uid = Digits.sharedInstance().session()?.userID {
                        let clientRef = self.ref.child("clients").child(uid)
                        clientRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                guard let sum = (snapshot.value as! NSDictionary)["sum"] as? Int else {
                                    return
                                }

                            if status == "awarenessApprove" {
                                if sum < price {
                                    self.showFailAlertView(price: price as Int)
                                } else {
                                    self.showSuccessAlertView(status: status! as String, time: time! as Int, price: price as Int)
                                }
                            } else {
                                self.showSuccessAlertView(status: status! as String, time: time! as Int, price: price as Int)
                            }
                                
                            
                        }, withCancel: nil)
                    }
                }
                
                }, withCancel: nil)
        }
    }
    
    
    
    func showFailAlertView(price: Int) {
        let alert = UIAlertController(title: "Не достаточно средств", message: "Чтобы эта задача пошла в работу на счету должно быть — \(price) руб.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Пополнить", style: .default, handler: { (action: UIAlertAction!) in
            let amountViewController = AmountViewController()
            let navController = UINavigationController(rootViewController: amountViewController)
            self.present(navController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showSuccessAlertView(status: String, time: Int, price: Int) {
        guard let taskId = task!.taskId else {
            return
        }
        
        var newstatus = ""
        if status == "awarenessApprove" {
            newstatus = "concept"
            let alert = UIAlertController(title: "Стоимость работ — \(price) руб.", message: "После нажатия кнопки «Подтверждаю» мы снимим сумму за первый этап", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Подтверждаю", style: .default, handler: { (action: UIAlertAction!) in
                self.navigationController?.popToRootViewController(animated: true)
                
                let bill = Double(price) * Double(0.1)
                
                self.sendBill(bill: Int(bill) as! Int)
                self.sendApproveToDB(taskId, status: status, newstatus: newstatus, time: time)
            }))
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: { (action: UIAlertAction!) in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
            
        } else if status == "conceptApprove" {
            newstatus = "design"
            
            let alert = UIAlertController(title: "Подтвердите", message: "После принятия черновика, вы не сможете вносить глобальные изменения в черновик", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Подтверждаю", style: .default, handler: { (action: UIAlertAction!) in
                self.navigationController?.popToRootViewController(animated: true)
                let bill = Double(price) * Double(0.4)
                self.sendBill(bill: Int(bill) as! Int)
                self.sendApproveToDB(taskId, status: status, newstatus: newstatus, time: time)
            }))
            
            
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: { (action: UIAlertAction!) in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        } else if status == "designApprove" {
            newstatus = "sources"
            
            let alert = UIAlertController(title: "Подтвердите", message: "После принятия чистовика вы не сможете вносить в него корректировки. Дизайнер будет готовить исходники.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Подтверждаю", style: .default, handler: { (action: UIAlertAction!) in
                self.navigationController?.popToRootViewController(animated: true)
                let bill = Double(price) * Double(0.5)
                self.sendBill(bill: Int(bill) as! Int)
                self.sendApproveToDB(taskId, status: status, newstatus: newstatus, time: time)
            }))
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: { (action: UIAlertAction!) in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    func sendBill(bill: Int) {
        
        if let uid = Digits.sharedInstance().session()?.userID {
            
            let clientRef = self.ref.child("clients").child(uid)
            clientRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let oldSum = (snapshot.value as! NSDictionary)["sum"] as? Int {
                    let newSum = Int(oldSum) - Int(bill)
                    print(newSum, oldSum, bill)
                    let values: [String: AnyObject] = ["sum": newSum as AnyObject]
                    clientRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print(error!)
                            return
                        }
                    })
                }
            }, withCancel: nil)
            
        }
    }
    
    func sendApproveToDB(_ taskId: String, status: String, newstatus: String, time: Int) {
        let taskRef = self.ref.child("tasks").child(taskId)
        
        var days: Int?
        if Int(time) <= 3 {
            days = 1
        } else if Int(time) > 3 && Int(time) <= 6 {
            days = 2
        } else if Int(time) > 6 && Int(time) <= 9 {
            days = 3
        }
        
        taskRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let startDate = NSNumber(value: Int(Date().timeIntervalSince1970))
            let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: days!, to: Date(), options: NSCalendar.Options.init(rawValue: 0))
            
            let endDate = NSNumber(value: Int(calculatedDate!.timeIntervalSince1970))
         
            
            let values : [String: AnyObject] = ["status": newstatus as AnyObject, "start": startDate as AnyObject, "end": endDate as AnyObject]
            taskRef.updateChildValues(values) { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                self.buttonView.buttonLabel.text = "Согласовано"
                self.buttonView.acceptTaskButtonView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
            }
            
            
            let statusLength = status.characters.count
            var step = ""
            
            if statusLength <= 7 {
                step = status
            } else {
                let index1 = status.characters.index(status.endIndex, offsetBy: -7)
                step = status.substring(to: index1)
            }
            
            let awStatus : [String: AnyObject] = ["status": "accept" as AnyObject]
            taskRef.child(step).updateChildValues(awStatus, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err as! NSError)
                    return
                }
            })
            
            let stepStatus : [String: AnyObject] = ["status": "none" as AnyObject]
            self.ref.child("tasks").child(taskId).child(newstatus).updateChildValues(stepStatus, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error as! NSError)
                    return
                }
            })
            
            }, withCancel: nil)
        
        
        
        self.buttonView.isUserInteractionEnabled = false
        self.dismiss(animated: true, completion: nil)
    }
  
}





class CustomCell: UICollectionViewCell, UIScrollViewDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    var conceptViewController: ConceptViewController?
    
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var imageWidthAnchor: NSLayoutConstraint?
    
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return iv
    }()
    
    let textView: UITextView = {
       let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Какой-то текст"
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.isEditable = false
        return tv
    }()
    
    let priceLabel: UILabel = {
       let ul = UILabel()
        ul.translatesAutoresizingMaskIntoConstraints = false
        ul.font = UIFont.systemFont(ofSize: 32)
        return ul
    }()
    
    let timeLabel: UILabel = {
        let ul = UILabel()
        ul.translatesAutoresizingMaskIntoConstraints = false
        ul.font = UIFont.systemFont(ofSize: 32)
        return ul
    }()
    
    let descriptView: UIView = {
       let uv = UIView()
        uv.backgroundColor = UIColor(r: 239, g: 239, b: 239)
        uv.translatesAutoresizingMaskIntoConstraints = false
        return uv
    }()
    
    let descriptLabel: UITextView = {
        let td = UITextView()
        td.text = "Изучите понимание задачи. Если дизайнер что-то не так понял, обсудите с ним. По нашему опыту, согласованное понимание ускоряет выполнение задачи"
        td.translatesAutoresizingMaskIntoConstraints = false
        td.backgroundColor = UIColor.clear
        td.font = UIFont.systemFont(ofSize: 14)
        td.textColor = UIColor(r: 125, g: 125, b: 125)
        td.isUserInteractionEnabled = false
        td.isEditable = false
        return td
    }()
    

    func setupView() {
        
        
        backgroundColor = UIColor.white
        addSubview(imageView)
        addSubview(textView)
        addSubview(descriptView)
        
        
        addConstraints("H:|[\(descriptView)]|", "H:|-16-[\(textView)]-16-|")
        addConstraints("V:|[\(descriptView)]-8-[\(textView)]")

        
        
        addConstraints(imageView.leftAnchor == self.leftAnchor,
                       imageView.topAnchor == self.topAnchor,
                       imageView.widthAnchor == self.widthAnchor,
                       imageView.heightAnchor == self.heightAnchor,
                       textView.heightAnchor == self.heightAnchor - 160,
                       descriptView.heightAnchor == 110
        )
        
        descriptView.addSubview(descriptLabel)
        descriptView.addConstraints("H:|-16-[\(descriptLabel)]-16-|")
        descriptView.addConstraints("V:|-8-[\(descriptLabel)]-8-|")
     
        
    }
    
    
    
    func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
       
        //Pro Tip: don't perform a lot of custom logic inside of a view class
        if let imageView = tapGesture.view as? UIImageView {
           performZoomInForImageView(imageView)
            
        }
    }
    
    
    
    
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    
    func performZoomInForImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        let zoomingImageView = ZoomingImageView(frame: startingFrame!)
        
        zoomingImageView.imageView.image = startingImageView.image
        
        zoomingImageView.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.backgroundColor = .white
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1

                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)
                
                zoomingImageView.imageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.imageView.center = keyWindow.center
                
                }, completion: nil)
        }
    }
    
  
    
    func handleZoomOut(_ tapGesture: UITapGestureRecognizer ) {
        
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame  = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                //                self.inputContainerView.alpha = 1
                }, completion: { (completed: Bool) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.isHidden = false
            })
        }
    }
    
 

   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
