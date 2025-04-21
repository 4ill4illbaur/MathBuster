
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var problemLabel: UILabel!
    @IBOutlet weak var timerContainerView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var resultField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    var dataModel: ViewControllerDataModel = ViewControllerDataModel()
 
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
        generateProblem()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        cheduleTimer()
    }
    
    
    
    func setupUI() {
        timerContainerView.layer.cornerRadius = 5
    }
    
    func generateProblem() {
        
        let selectedIndex = segmentedControl.selectedSegmentIndex
        let range = dataModel.ranges[selectedIndex]
        
        
        let firstDigit = Int.random(in: range)
        let arithmeticOperation: String = ["+", "-", "*", "/"].randomElement()!
       
        
        var startingInteger = range.lowerBound
        var endingInteger = range.upperBound
        if  arithmeticOperation == "/" && startingInteger == 0 {
            startingInteger = 1
        } else if arithmeticOperation == "-" {
            endingInteger = firstDigit
        }
        
        let secondDigit = Int.random(in: startingInteger...endingInteger)
       
        
        problemLabel.text = ("\(firstDigit) \(arithmeticOperation) \(secondDigit) = ")
       
        switch arithmeticOperation {
        case "+":
            dataModel.result = Double(firstDigit + secondDigit)
        case "-":
            dataModel.result = Double(firstDigit - secondDigit)
        case "*":
            dataModel.result = Double(firstDigit) * Double(secondDigit)
        case "/":
            dataModel.result = Double(firstDigit) / Double(secondDigit)
        default:
            dataModel.result = nil
        }
    }
    
    func cheduleTimer() {
        dataModel.countDown = 30
        dataModel.timer?.invalidate()
        dataModel.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc
    func updateTimer() {
        dataModel.countDown -= 1
        var seconds = String (format: "%02d", dataModel.countDown)
        
        
        timerLabel.text = "00: \(seconds)"
        progressView.progress = Float(30 - dataModel.countDown) / 30
        print("ProgressView: \(progressView.progress)")
        
        if dataModel.countDown <= 0 {
            finishTheGame()
        }
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        guard let text = resultField.text else {
            print("Text is nil")
            return
        }
        guard !text.isEmpty else {
            print("Text is empty")
            return
        }
        guard let newResult = Double(text) else {
            print("Could not convert text: \(text)() to Double")
            return
        }
        
        if newResult == dataModel.result {
            print("Correct!")
            let selectedIndex = segmentedControl.selectedSegmentIndex
            dataModel.score += dataModel.scoreAmount[selectedIndex]
            scoreLabel.text = "Score: \(dataModel.score)"
            
        } else {
            print("Incorrect!")
        }
        generateProblem()
        resultField.text = nil
    }
    
    
    @IBAction func restartPressed(_ sender: Any) {
        restart()
        
    }
    func restart() {
        dataModel.score = 0
        scoreLabel.text = "Score: 0"
        
        
        generateProblem()
        
        cheduleTimer()
        
        resultField.isEnabled = true
        submitButton.isEnabled = true
        
    }
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
       // print("sender.selectedSegmentIndex)
        restart()
    }
    
    func finishTheGame() {
        dataModel.timer?.invalidate()
        resultField.isEnabled = false
        submitButton.isEnabled = false
        
        askForName()
    }
    
    func askForName() {
        let alertController = UIAlertController(title: "Game Over", message: "Your score is \(dataModel.score)", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter your name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alertController.textFields?.first else {
                print("Absent")
                return
            }
            guard let text = textField.text, !text.isEmpty  else {
                print("Nil or epmty")

                return
            }
            print("\(text)")
            
            
            self.saveUserScoreAsStruct(name: text)
        }
        alertController.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
//        let skipAction = UIAlertAction(title: "Skip", style: .destructive)
//        alertController.addAction(skipAction)
        
        present(alertController, animated: true)
        }
        
    
    func saveUserScoreAsStruct(name: String) {
        let userScore = UserScore(name: name, score: dataModel.score)
        var level: Level?
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            level = .easy
        case 1:
            level = .medium
        case 2:
            level = .hard
        default:
            ()
        }
        
        guard let level = level else {
            print("Level is nil because index out of [0,1,2]")
            return
        }
        
        let userScoreArray: [UserScore] = ViewController.getAllUserScoress(level: level) + [userScore]
        
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(userScoreArray)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: level.key())
            
        } catch {
            print("Mistake")
        }
    }
    
    static func getAllUserScoress(level: Level) -> [UserScore] {
        var result: [UserScore] = []
        
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.object(forKey: level.key()) as? Data
                {
                do {
                    let decoder = JSONDecoder()
                    result = try decoder.decode([UserScore].self, from: data)
                }
                catch {
                    print("Something wrong \(error.localizedDescription)")
                }
            }
        
        return result
    }
    
    func saveUserScore(name: String) {
        let userScore: [String: Any] = ["name": name, "score": dataModel.score]
        let userScoreArray: [[String: Any]] = getUserScoreArray() + [userScore]
        
        
        
        print("userScore: \(userScore)")
        let userDefaults = UserDefaults.standard
        userDefaults.set(userScoreArray, forKey:  ViewControllerDataModel.userScoreKey)
    }
    
    func getUserScoreArray() -> [[String: Any]] {
        let userDefaults = UserDefaults.standard
        let array = userDefaults.array(forKey: ViewControllerDataModel.userScoreKey) as? [[String: Any]]
         return array ?? []
         
    }
}

struct ViewControllerDataModel {
    var timer: Timer?
    var countDown = 30
    var result: Double?
    var score: Int = 0
    let ranges = [0...9, 10...99, 100...999]
    var scoreAmount: [Int] = [1, 2, 3]
    
    static let userScoreKey = "userScore"
    
}

struct UserScore: Codable {
    let name: String
    let score: Int
    
}

enum Level {
    case easy
    case medium
    case hard
    
    func key() -> String {
        switch self {
        case .easy:
            return "easyUserScore"
        case .medium:
            return "mediumUserScore"
        case .hard:
            return "hardUserScore"
        }
    }
}
