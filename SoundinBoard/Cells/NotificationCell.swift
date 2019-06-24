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

class NotificationCell: UITableViewCell {

    /*--- VIEWS ---*/
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Layout
        avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
    }

    
}// ./ end
