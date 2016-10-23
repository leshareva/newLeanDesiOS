import UIKit
import Firebase

class TaskCell: UITableViewCell {
    
    
    var task: Task? {
        didSet {
            
            setupNameAndProfileImage()
            
            if let seconds = task?.start?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.stringFromDate(timestampDate)
            }
        }
    }
    
    private func setupNameAndProfileImage() {
        if let Id = task?.taskId {
            let ref = FIRDatabase.database().reference().child("tasks").child(Id)
            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["text"] as? String
                    
                    if let taskImageUrl = dictionary["taskImageUrl"] as? String {
                        self.taskImageView.loadImageUsingCashWithUrlString(taskImageUrl)
                        
                    }
                }
                }, withCancelBlock: nil)
        }
    }
    
    let taskImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage.gifWithName("spinner-duo")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .ScaleAspectFill
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        return iv
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Right
        return label
    }()
    
    let notificationsLabel: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 48, g: 140, b: 229)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 7
        view.layer.masksToBounds = true
        return view
    }()
    
    let taskTextView: UITextView = {
        let tv = UITextView()
        tv.text = "Очень много текста должно быть в одном поле. И желательно бы все это видеть"
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
  
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(taskImageView)
        
        
        taskImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        taskImageView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        taskImageView.widthAnchor.constraintEqualToConstant(50).active = true
        taskImageView.heightAnchor.constraintEqualToConstant(50).active = true
        
        
        
        addSubview(notificationsLabel)
        notificationsLabel.topAnchor.constraintEqualToAnchor(taskImageView.topAnchor, constant: 2).active = true
        notificationsLabel.leftAnchor.constraintEqualToAnchor(taskImageView.leftAnchor, constant: 2).active = true
        notificationsLabel.widthAnchor.constraintEqualToConstant(14).active = true
        notificationsLabel.heightAnchor.constraintEqualToConstant(14).active = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 66, y: textLabel!.frame.origin.y - 2, width: self.frame.width - 84, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 66, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        textLabel?.numberOfLines = 2
        textLabel?.font = UIFont.systemFontOfSize(14)
        detailTextLabel?.textColor = UIColor(r: 140, g: 140, b: 140)
        detailTextLabel?.font = UIFont.systemFontOfSize(12)
        
        
        addSubview(timeLabel)
        timeLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -16).active = true
        timeLabel.topAnchor.constraintEqualToAnchor(textLabel?.bottomAnchor, constant: 2).active = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}