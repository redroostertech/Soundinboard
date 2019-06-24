/*==================================================
 Askk
 
 © XScoder 2019
 All Rights reserved
 
 /*
 RE-SELLING THIS SOURCE CODE TO ANY ONLINE MARKETPLACE IS A SERIOUS COPYRIGHT INFRINGEMENT.
 YOU WILL BE LEGALLY PROSECUTED
 */
===================================================*/

import UIKit

class AnswerCell: UITableViewCell {

    /*--- VIEWS ---*/
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var answeredLabel: UILabel!
    @IBOutlet weak var answerTxt: UITextView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var bestAnswerLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var dislikesLabel: UILabel!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var setBestAnswerButton: UIButton!
    @IBOutlet weak var answerUserButton: UIButton!
    @IBOutlet weak var answerImgButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Layout
        avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
        answerImgButton.imageView?.contentMode = .scaleAspectFill
        answerImgButton.layer.cornerRadius = 6
    }

    
}// ./ end
