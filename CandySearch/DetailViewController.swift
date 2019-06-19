
import UIKit

class DetailViewController: UIViewController {
  
    @IBOutlet weak var detailDegreeLabel: UILabel!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
  @IBOutlet weak var candyImageView: UIImageView!
  
    var detailCandy: Candy? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let detailCandy = detailCandy {
            if let detailDescriptionLabel = detailDescriptionLabel, let detailDegreeLabel = detailDegreeLabel, let candyImageView = candyImageView {
                detailDescriptionLabel.text = detailCandy.name
                candyImageView.image = UIImage(named: detailCandy.name)
                detailDegreeLabel.text = detailCandy.degree
                title = detailCandy.name
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
