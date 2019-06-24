import UIKit

class QuestionCell: UITableViewCell {

    /*--- VIEWS ---*/
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answeredByLabel: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Layout
        avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
        avatarImg.layer.borderWidth = 2
        avatarImg.layer.borderColor = UIColor.white.cgColor
    }

    
}// ./ end
