import UIKit
import Firebase

class TaskCell: UITableViewCell {
    
    
    var task: Task? {
        didSet {
            
            setupNameAndProfileImage()
            
            if let seconds = task?.start?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
        }
    }
    
    fileprivate func setupNameAndProfileImage() {
        if let Id = task?.taskId {
            let ref = FIRDatabase.database().reference().child("tasks").child(Id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["text"] as? String
                    
                    if let taskImageUrl = dictionary["taskImageUrl"] as? String {
                        self.taskImageView.loadImageUsingCashWithUrlString(taskImageUrl)
                    }
                }
                }, withCancel: nil)
        }
    }
    
    let taskImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage.gifWithName("spinner-duo")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        return iv
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.textAlignment = .right
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
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(taskImageView)
        
        
        taskImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        taskImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        taskImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        taskImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        
        addSubview(notificationsLabel)
        notificationsLabel.topAnchor.constraint(equalTo: taskImageView.topAnchor, constant: 2).isActive = true
        notificationsLabel.leftAnchor.constraint(equalTo: taskImageView.leftAnchor, constant: 2).isActive = true
        notificationsLabel.widthAnchor.constraint(equalToConstant: 14).isActive = true
        notificationsLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 66, y: textLabel!.frame.origin.y - 2, width: self.frame.width - 84, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 66, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        textLabel?.numberOfLines = 2
        textLabel?.font = UIFont.systemFont(ofSize: 14)
        detailTextLabel?.textColor = UIColor(r: 140, g: 140, b: 140)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        
        
        addSubview(timeLabel)
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        timeLabel.topAnchor.constraint(equalTo: (textLabel?.bottomAnchor)!, constant: 2).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
