

import UIKit
import Swiftstraints
import Firebase
import Alamofire
import DigitsKit

class CompleteViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate  {
    
    var task: Task?
    var sources = [File]()
    let customCellIdentifier = "cellId"
    
    var timer: Timer?
    var sourcesDictionary = [String: File]()

    lazy var archiveButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.setTitleColor( .black, for: .normal)
        btn.setTitle("Принимаю задачу", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
//        btn.layer.borderWidth = 1
//        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.addTarget(self, action: #selector(handleComplete), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(handleDone))
        setupView()
    }
    
    
    func setupView() {
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ConceptCell.self, forCellWithReuseIdentifier: customCellIdentifier)
        
        
        view.addSubview(archiveButton)
        
        
        view.addConstraints("H:|-16-[\(archiveButton)]-16-|")
        view.addConstraints("V:[\(archiveButton)]-16-|")
        view.addConstraints(archiveButton.heightAnchor == 40)
        
    
        view.backgroundColor = .white
        
        
        
    }
    
 
    
    func observeSources() {
        
        guard let taskId = task?.taskId else {
            return
        }
        
        
        let ref = FIRDatabase.database().reference()
        ref.child("tasks").child(taskId).child("sources").observe(.childAdded, with: {(snapshot) in
            
            let fileKey = snapshot.key
            
            
            ref.child("files").child(fileKey).observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let source = File(dictionary: dictionary)
                    self.sourcesDictionary[snapshot.key] = source

                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                    })
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    
    
    
    
   
    
    func handleComplete() {
        guard let taskId = self.task?.taskId else {
            return
        }
        
        let parameters: Parameters = [
            "taskId": taskId,
            "status": "archive"
        ]
        
        Alamofire.request("\(Server.serverUrl)/tasks/update",
            method: .post,
            parameters: parameters)
        
        dismiss(animated: true, completion: nil)
    }
    
    

    
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let file = sources[indexPath.row]
//        
//        let myWebsite = NSURL(string: file.source!)
//        
//        guard let url = myWebsite else {
//            print("nothing found")
//            return
//        }
//        
//        let shareItems:Array = [url]
//        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
//        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
//        self.present(activityViewController, animated: true, completion: nil)
//        
//    }
    
    

    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let sourceTitle = SourceTitle(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
//        sourceTitle.backgroundColor = .white
//        
//        if let price = task?.price  {
//            sourceTitle.priceLabel.attributedText = attributedText(string: "Оплачено\n\(Int(price)) рубля" as NSString, range: String(describing: Int(price)))
//            
//            
//        }
//        
//        if let designerId = task?.toId {
//            let ref = FIRDatabase.database().reference()
//            ref.child("designers").child(designerId).observeSingleEvent(of: .value, with: { (snapshot) in
//                
//                if let photoUrl = (snapshot.value as! NSDictionary)["photoUrl"] as? String {
//                    sourceTitle.userImageView.loadImageUsingCashWithUrlString(photoUrl)
//                }
//                
//                guard let name = (snapshot.value as! NSDictionary)["firstName"] as? String else {
//                    return
//                }
//                
//                sourceTitle.userNameLabel.text = name
//                
//                
//            }, withCancel: nil)
//        }
//        
//        
//        
//        sourceTitle.closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDone)))
//        
//        return sourceTitle
//    }
//    
    
    
    
    
    func handleDone() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func handleShare(link: String) {

        let myWebsite = NSURL(string: link as String)
        
        guard let url = myWebsite else {
            print("nothing found")
            return
        }
        
        let shareItems:Array = [url]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: nil)
        
        
    }

    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 280
        
        let source = sources[indexPath.item]
        let width = UIScreen.main.bounds.width
        let screenWidth: CGFloat = view.frame.width
        
        if source.thumbnailLink != nil {
            
            if let imageWidth = source.width?.floatValue, let imageHeight = source.height?.floatValue {
                //h1 / w1 = h2 / w2
                //solve for h1
                //h1 = h2 / w2 * w1
                height = CGFloat(imageHeight / imageWidth * Float(screenWidth))
            }
        }
        
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sources.count
    }
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! ConceptCell
        
        let source = sources[indexPath.item]
        
        
        if let imageUrl = source.thumbnailLink {
            print(imageUrl)
            cell.imageView.loadImageUsingCashWithUrlString(imageUrl)
            cell.textView.isHidden = true
            cell.priceLabel.isHidden = true
            cell.timeLabel.isHidden = true
            cell.descriptView.isHidden = true
            
            
            if let sourceUrl = source.source {
                let tappy = MyTapGesture(target: self, action: #selector(self.showShareButtons(_:)))
                tappy.anyobj = ["jpgLink": imageUrl, "sourceLink": sourceUrl]
                cell.shareIcon.addGestureRecognizer(tappy)
            }
            
            
            
        }
        return cell
    }
    
    
    func showShareButtons(_ tapGesture: MyTapGesture) {
        guard let jpgLink = tapGesture.anyobj?["jpgLink"], let sourceLink = tapGesture.anyobj?["sourceLink"] else {
            return
        }
        
        let alertController = UIAlertController(title: "Поделиться файлом", message: "Отправьте ссылку на исходник или на джепег друзьям", preferredStyle: .actionSheet)
        
        let sendButton = UIAlertAction(title: "Поделиться JPG", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
            
            self.handleShare(link: jpgLink as! String)
            
        })
        
        let deleteButton = UIAlertAction(title: "Поделиться исходником", style: .destructive, handler: { (action) -> Void in
            self.handleShare(link: sourceLink as! String)
        })
        
        let cancelButton = UIAlertAction(title: "Отмена", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        
        alertController.addAction(sendButton)
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
        
    }
    

    
//    func attributedText(string: NSString, range: String)->NSAttributedString{
//        
//        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14.0)])
//        
//        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24.0)]
//        
//        attributedString.addAttributes(boldFontAttribute, range: string.range(of: range))
//        
//        return attributedString
//    }
//    
}
