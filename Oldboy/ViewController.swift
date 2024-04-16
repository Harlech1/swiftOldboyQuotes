//
//  ViewController.swift
//  Oldboy
//
//  Created by Türker Kızılcık on 13.04.2024.
//

import UIKit

class ViewController: UIViewController {

    let script = Scripts.script.rawValue

    var timer: Timer?

    var scriptsLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        return label
    }()

    var getLinesButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemBlue
        button.setTitle("Random", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.textColor = UIColor.white
        button.layer.cornerRadius = 8
        return button
    }()

    var randomQuote : String?

    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        setupConstraints()

        randomQuote = getRandomLines()
        scriptsLabel.text = randomQuote

        /// uygulamaya girip çıkın, timer ile runloop yaptığımda notifikasyonlar bir yerden sonra bozuluyor -- tr
        /// open app and quit in 5 seconds, notifications crash after getting so much notifications with timer & runloop --en
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.sendNotification()
        }

        getLinesButton.addTarget(self, action: #selector(setLabelTitleToQuote), for: .touchUpInside)
    }

    @objc func setLabelTitleToQuote() {
        randomQuote = getRandomLines()
        scriptsLabel.text = randomQuote
    }

    func addSubviews() {
        view.addSubview(scriptsLabel)
        view.addSubview(getLinesButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            scriptsLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            scriptsLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            getLinesButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 130),
            getLinesButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -130),
            getLinesButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
        ])
    }

    func getRandomLines() -> String {
        let cleansedText = removeEmptyLines(text: script)
        let delimitedArray = convertToCommaSeparatedArray(text: cleansedText)
        let randomElement = delimitedArray.randomElement()!

        guard
            let randomIndex = delimitedArray.firstIndex(of: randomElement),
            randomIndex > 0,
            randomIndex < delimitedArray.count - 1
        else {
            return "sorry"
        }

        return "\(delimitedArray[randomIndex-1])\n\(delimitedArray[randomIndex])\n\(delimitedArray[randomIndex+1])"
    }

    func convertToCommaSeparatedArray(text: String) -> [String] {
        let replacedText = text.replacingOccurrences(of: "\n", with: ",")
        let array = replacedText.components(separatedBy: ",")
        return array
    }

    func removeEmptyLines(text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        let nonEmptyLines = lines.filter { !$0.isEmpty }
        let joinedText = nonEmptyLines.joined(separator: "\n")
        return joinedText
    }

    @objc func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Oldboy Quotes"
        content.body = "\(randomQuote ?? "didn't work")"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { _ in}
    }
}

