

import UIKit

class WelcomeViewController: UIViewController {
  
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: [[UserScore]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ScoreTableViewCell", bundle: nil), forCellReuseIdentifier: ScoreTableViewCell.identifier)
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.refreshControl
        = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(getUserScore), for: .valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserScore()
    }
    
    @objc
    func getUserScore() {
       tableView.refreshControl?.endRefreshing()
        
        let easyUserScoreList = ViewController.getAllUserScoress(level: .easy)
        let mediumUserScoreList = ViewController.getAllUserScoress(level: .medium)
        let hardUserScoreList = ViewController.getAllUserScoress(level: .hard)
        
        self.dataSource = [easyUserScoreList, mediumUserScoreList, hardUserScoreList]
       // self.userScoreArrayOfDictionaries = ViewController.getAllUserScoress()
    }

    
    
    func gerUserSingleText(indexPath: IndexPath) -> String? {
        let userScore: UserScore = dataSource[indexPath.section][indexPath.row]
        let text = "Name: \(userScore.name), Score: \(userScore.score)"
        return text
        
    }
}

//MARK: UITableViewDatasource & UITableViewDelegate
extension WelcomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScoreTableViewCell.identifier, for: indexPath) as! ScoreTableViewCell
        
       
            
        cell.scoreTextLabel.text = gerUserSingleText(indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = ScoreDetailViewController()
        viewController.text = gerUserSingleText(indexPath: indexPath)
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Easy"
        case 1:
            return "Medium"
        case 2:
            return  "Hard"
        default:
            return "default"
        }
    }
}



