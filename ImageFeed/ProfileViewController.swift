//
// Created by Ruslan S. Shvetsov on 09.04.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
   
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var loginNameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    
    @IBAction private func didTapLogoutButton() {
    }
    
}
