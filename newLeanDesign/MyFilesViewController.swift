import UIKit
import Alamofire
import AlamofireImage
import SWXMLHash
import CryptoSwift
import DigitsKit
import Firebase
import Toast_Swift


class MyFilesViewController: UIViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UICollectionViewDataSource, UIActionSheetDelegate {
    
    var collectionView: UICollectionView!
    var cellId = "cellId"
    var files = [File]()
    var filesDictionary = [String: File]()
    var database = FIRDatabase.database().reference()
    var timer: Timer?
    var addFileView: AddFileView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.observeUserFiles()
        
        self.addFileView = AddFileView(frame: CGRect(x: 0, y: -230, width: self.view.frame.size.width, height: 230))
        self.addFileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShareLink)))
        self.view.addSubview(self.addFileView)
        

        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        let screenWidth  = UIScreen.main.bounds.width - 60
        layout.itemSize = CGSize(width: screenWidth / 3, height: 120)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MyFilesCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "point")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddFile))
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
        
    }
    
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                self.slideDown()
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    func slideDown() {
        guard let uid = Digits.sharedInstance().session()?.userID else {
            print("No Digits")
            return
        }
        
        let site = Server.desktopWeb
        let myWebsite = NSURL(string:"\(site)/upload-files/?=\(uid)")
        
        guard let url = myWebsite else {
            print("nothing found")
            return
        }
        
        UIPasteboard.general.string = String(describing: url)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.addFileView.frame = CGRect(x: 0, y: 0, width: (self.view.window?.frame.size.width)!, height: 230)
        }, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MyFilesCell
        let file = files[indexPath.item]
    
        if file.thumbnailLink != nil {
           cell.thumbImageView.loadImageUsingCashWithUrlString(file.thumbnailLink!)
        } else {
            cell.thumbImageView.image = UIImage(named: "psd")
        }
        
        return cell
    }
    
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return files.count
    }

     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView = MyFilesHeader()
        return reusableView
    }
    
    
    
    func observeUserFiles() {
        guard let uid = Digits.sharedInstance().session()?.userID else {
            print("No Digits Id")
            return
        }
        
        let ref = FIRDatabase.database().reference()
        ref.child("userFiles").child(uid).observe(.childAdded, with: { (snapshot) in

            guard let fileId = (snapshot.value as! NSDictionary)["id"] as? String else {
                return
            }
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let file = File(dictionary: dictionary)
                self.filesDictionary[fileId] = file
            }
            
            self.attemptReloadTable()
            
            
        }, withCancel: nil)
        
        
    }
    

    private func attemptReloadTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.08, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    
    func handleReloadTable() {
        self.files = Array(self.filesDictionary.values)
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    
    func handleAddFile() {
        
        let alert = UIAlertController(title: "Загрузить файл", message: "Какой файл загрузим?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Фото", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
        }))
        
        alert.addAction(UIAlertAction(title: "Другой файл", style: .default , handler:{ (UIAlertAction)in
            
            guard let uid = Digits.sharedInstance().session()?.userID else {
                print("No Digits")
                return
            }
            
            let site = Server.desktopWeb
            let myWebsite = NSURL(string:"\(site)/upload-files/?=\(uid)")
            
            guard let url = myWebsite else {
                print("nothing found")
                return
            }

            UIPasteboard.general.string = String(describing: url)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.addFileView.frame = CGRect(x: 0, y: 0, width: (self.view.window?.frame.size.width)!, height: 230)
            }, completion: nil)
            
        }))
        

        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        
        self.present(alert, animated: true, completion: {
            
        })
        
    }
    
    
    
    func handleShareLink() {
        guard let uid = Digits.sharedInstance().session()?.userID else {
            print("No Digits")
            return
        }
        
        let site = Server.desktopWeb
        let myWebsite = NSURL(string:"\(site)/upload-files/?=\(uid)")
        
        guard let url = myWebsite else {
            print("nothing found")
            return
        }
        
        let shareItems:Array = [url]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.addFileView.frame = CGRect(x: 0, y: -230, width: (self.view.window?.frame.size.width)!, height: 230)
            }, completion: nil)
        })
    }
    
}


