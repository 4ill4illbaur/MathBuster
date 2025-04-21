

import UIKit

class ScoreDetailViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    
    var text: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = text

       
    }

    @IBAction func goBackButtonPressed(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
    }
    

}
