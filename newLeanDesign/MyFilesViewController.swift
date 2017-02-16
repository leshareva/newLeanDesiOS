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
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 80, right: 10)
        let screenWidth  = UIScreen.main.bounds.width - 40
        layout.itemSize = CGSize(width: screenWidth / 2, height: 120)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MyFilesCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "point")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddFile))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Добавить", style: .plain, target: self, action: #selector(handleAddFile))
    }
    
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                 print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                self.slideUp()
            default:
                break
            }
        }
    }
    
    
    
    func slideUp() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.addFileView.frame = CGRect(x: 0, y: -230, width: (self.view.window?.frame.size.width)!, height: 230)
        }, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MyFilesCell
        let file = files[indexPath.item]
    
        if file.thumbnailLink != nil {
           cell.thumbImageView.loadImageUsingCashWithUrlString(file.thumbnailLink!)
        } else {
            cell.extesionsImageView.image = UIImage(named: "psd")
        }
        
        cell.nameLabel.text = file.name
        return cell
    }
    
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return files.count
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let file = files[indexPath.row]
        
        let imageUrl = file.source
        let myWebsite = NSURL(string: imageUrl!)
        
        guard let url = myWebsite else {
            print("nothing found")
            return
        }
        
        let shareItems:Array = [url]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView = MyFilesHeader()
        return reusableView
    }
    
    
    
    
    
    
}


