

import UIKit
import Swiftstraints
import Firebase
import Alamofire
import DigitsKit

class CompleteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var task: Task?
    var sources = [Source]()
    let cellId = "cellId"
    var tableView: UITableView  =  UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    var timer: Timer?
    var sourcesDictionary = [String: Source]()

    lazy var archiveButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.setTitleColor( .black, for: .normal)
        btn.setTitle("В архив", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.addTarget(self, action: #selector(handleComplete), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    
    func setupView() {
        
        view.addSubview(tableView)
        view.addSubview(archiveButton)
        
        view.addConstraints("H:|-16-[\(archiveButton)]-16-|")
        view.addConstraints("V:[\(archiveButton)]-16-|")
        view.addConstraints(archiveButton.heightAnchor == 40)
        
        let screenSize: CGRect = UIScreen.main.bounds
        tableView.frame         =   CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height - 70);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.register(SourceCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.backgroundColor = .white

        view.backgroundColor = .white
        
        observeSources()
        
    }
    
 
    
    func observeSources() {
        guard let taskId = task?.taskId else {
            return
        }
        
        
        let ref = FIRDatabase.database().reference()
        ref.child("tasks").child(taskId).child("sources").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let source = Source(dictionary: dictionary)
                self.sourcesDictionary[snapshot.key] = source
            }
            
            self.attemptReloadTable()
            

        }, withCancel: nil)
    }
    
    
    
    private func attemptReloadTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    
    func handleReloadTable() {
        self.sources = Array(self.sourcesDictionary.values)
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func handleComplete() {
        guard let taskId = self.task?.taskId else {
            return
        }
        
        let parameters: Parameters = [
            "taskId": taskId
        ]
        
        Alamofire.request("\(Server.serverUrl)/closeTask",
            method: .post,
            parameters: parameters)
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SourceCell
        
        let source = sources[indexPath.row]
        cell.textLabel?.text = source.name
            print(sources)
        if (source.thumbnailLink != nil) {
            cell.thumbImageView.loadImageUsingCashWithUrlString(source.thumbnailLink!)
        } else {
            if source.extension == "psd" {
                cell.extensionImageView.image = UIImage(named: "psd")
                cell.thumbImageView.isHidden = true
            } else {
                
            }
        }
        
        if let id = source.id {
            let tappy = MyTapGesture(target: self, action: #selector(self.handleShare(_:)))
            cell.linkImageView.addGestureRecognizer(tappy)
            tappy.string = id
        }
        
        

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let source = sources[indexPath.row]
        
        let id = source.id
        let myWebsite = NSURL(string:"https://drive.google.com/file/d/\(id!)")
        
        guard let url = myWebsite else {
            print("nothing found")
            return
        }
        
        let shareItems:Array = [url]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sourceTitle = SourceTitle(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        sourceTitle.backgroundColor = .white
        
        if let price = task?.price  {
            sourceTitle.priceLabel.attributedText = attributedText(string: "Оплачено\n\(Int(price)) рубля" as NSString, range: String(describing: Int(price)))
            
            
        }
        
        if let designerId = task?.toId {
            let ref = FIRDatabase.database().reference()
            ref.child("designers").child(designerId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let photoUrl = (snapshot.value as! NSDictionary)["photoUrl"] as? String {
                    sourceTitle.userImageView.loadImageUsingCashWithUrlString(photoUrl)
                }
                
            }, withCancel: nil)
        }
        
        
        
        sourceTitle.closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDone)))
        
        return sourceTitle
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 230
    }
    
    func handleDone() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func handleShare(_ sender : MyTapGesture) {
        
        let id = sender.string! as String
        let myWebsite = NSURL(string:"https://drive.google.com/file/d/\(id)")
        
        guard let url = myWebsite else {
            print("nothing found")
            return
        }
        
        let shareItems:Array = [url]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: nil)
        
        
    }
    
    
    
    func attributedText(string: NSString, range: String)->NSAttributedString{
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14.0)])
        
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24.0)]
        
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: range))
        
        return attributedString
    }
    
}
