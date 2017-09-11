//
//  ViewController.swift
//  ANR Scoreboard 2
//
//  Created by mark on 2/09/17.
//  Copyright © 2017 mark. All rights reserved.
//

import AppKit

class ViewController: NSViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var comboBoxPlayerA: NSComboBox!
    @IBOutlet weak var comboBoxPlayerB: NSComboBox!
    @IBOutlet weak var updateNamesButtonItem: NSButton!
    @IBOutlet weak var scoreTextPlayerA: NSTextField!
    @IBOutlet weak var scoreTextPlayerB: NSTextField!
    @IBOutlet weak var idTextPlayerA: NSTextField!
    @IBOutlet weak var idTextPlayerB: NSTextField!
    @IBOutlet weak var playerARunnerRadioButton: NSButton!
    @IBOutlet weak var playerACorpRadioButton: NSButton!
    @IBOutlet weak var playerBRunnerRadioButton: NSButton!
    @IBOutlet weak var playerBCorpRadioButton: NSButton!
    @IBOutlet weak var playerAFlatlineWinCheckBox: NSButton!
    @IBOutlet weak var playerBFlatlineWinCheckBox: NSButton!
    
    
    
    // MARK: - Properties
    
    let outputFolderPath = "ANR-Scoreboard/Output/"
    
    let fileNameA = "PlayerAName.txt"
    let fileNameB = "PlayerBName.txt"
    let fileScoreA = "PlayerAScore.txt"
    let fileScoreB = "PlayerBScore.txt"
    let fileWinA = "PlayerAWon.txt"
    let fileWinB = "PlayerBWon.txt"
    let fileIDTextA = "PlayerAID.txt"
    let fileIDTextB = "PlayerBID.txt"
    let fileFlatlinedA = "PlayerAFlatlined.txt"
    let fileFlatlinedB = "PlayerBFlatlined.txt"
    
    var allPlayers = [Tournament.Player]()
    var playerNames = [String]()
    
    var selectedInputFile: URL? {
        didSet {
            if let selectedInputFile = selectedInputFile {
                playerNames = getPlayerNames(fileURL: selectedInputFile)
                comboBoxPlayerA.reloadData()
                comboBoxPlayerB.reloadData()
            } else {
                print("No file chosen")
            }
        }
    }
    var playerAscore = Score()
    var playerBscore = Score()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        comboBoxPlayerA.usesDataSource = true
        comboBoxPlayerB.usesDataSource = true
        comboBoxPlayerA.dataSource = self
        comboBoxPlayerB.dataSource = self
        
        comboBoxPlayerA.delegate = self
        comboBoxPlayerB.delegate = self
        
        scoreTextPlayerA.stringValue = "0"
        scoreTextPlayerB.stringValue = "0"
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

// MARK: - ComboBox datasource and notification delegate

extension ViewController: NSComboBoxDataSource, NSComboBoxDelegate {
    
    // Returns the number of items that the data source manages for the combo box
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return playerNames.count
    }
    
    // Returns the object that corresponds to the item at the specified index in the combo box
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return playerNames[index]
    }
    
    // When making player name selections from the Combo Box, also send changes to the faction info fields and files
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        let comboBox: NSComboBox = (notification.object as? NSComboBox)!
        let key = comboBox.indexOfSelectedItem
        if let name = self.comboBox(comboBox, objectValueForItemAt: key) as? String {
            if comboBox == self.comboBoxPlayerA {
                let whichBox = "A"
                if playerARunnerRadioButton.state == NSControl.StateValue.on {
                    updatefactionInfoFromName(playerName: name, whichBox: whichBox, playingAsRunner: true)
                } else {
                    updatefactionInfoFromName(playerName: name, whichBox: whichBox, playingAsRunner: false)
                }
            } else {
                let whichBox = "B"
                if playerBRunnerRadioButton.state == NSControl.StateValue.on {
                    updatefactionInfoFromName(playerName: name, whichBox: whichBox, playingAsRunner: true)
                } else {
                    updatefactionInfoFromName(playerName: name, whichBox: whichBox, playingAsRunner: false)
                }
            }
        }
    }
}

// MARK: - File IO functions

extension ViewController {
    
    // Take content variable and write it file name variable
    
    func writeToOutputFile(content: String, fileName: String) {
        
        let fileManager = FileManager.default
        guard let home = try? fileManager.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            return
        }
        let outputFolderURL = home.appendingPathComponent(outputFolderPath)
        let fileURL = outputFolderURL.appendingPathComponent(fileName)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed to write to: \(fileURL)")
            print(error)
        }
    }
    
    // Decode the JSON file into a Tournament dictionary & then a player's name array
    
    func getPlayerNames(fileURL: URL) -> [String] {
                
        let tournament = try? Tournament(contentsOf: fileURL)
        
        // Reset in case of chosing a new Tournament file
        playerNames.removeAll()
        allPlayers.removeAll()
        
        // Loop through the Tournament "players" section of the JSON Data dictionary and create a players array
        if let t = tournament?.players {
            for person in t {
                let player = Tournament.Player(name: person.name,
                                               runnerFaction: person.runnerFaction,
                                               runnerIdentity: person.runnerIdentity,
                                               corpFaction: person.corpFaction,
                                               corpIdentity: person.corpIdentity)
                allPlayers.append(player)
            }
            allPlayers.sort { $0.name < $1.name }
            
            // Create another array as just player names for use as a comboxBox datasource
            
            for player in allPlayers {
                let playerName = player.name
                playerNames.append(playerName)
            }
            return playerNames
        } else {
            print("No Tournament Instance created from selected JSON file")
            let empty = [String]()
            return empty
        }
    }
    
    // Find the corp or runner faction / identity info for a given name and return array
    
    func updatefactionInfoFromName(playerName: String, whichBox: String, playingAsRunner: Bool) {
        
        if playingAsRunner {                                        // Playing as Runner
            var factionInfo = allPlayers
                .filter {$0.name.contains(playerName)}
                .map { $0.runnerFaction }
            factionInfo.append(contentsOf: allPlayers
                .filter {$0.name.contains(playerName)}
                .map { $0.runnerIdentity })
            let factionInfoFlat = factionInfo.flatMap({ $0 }).joined(separator: ": ")
            switch whichBox {
            case "A":
                idTextPlayerA.stringValue = factionInfoFlat
            case "B":
                idTextPlayerB.stringValue = factionInfoFlat
            default :
                print("WhichBox switch case A or B not found")
            }
        } else {                                                    // Playing as Corp
            var factionInfo = allPlayers
                .filter {$0.name.contains(playerName)}
                .map { $0.corpFaction }
            factionInfo.append(contentsOf: allPlayers
                .filter {$0.name.contains(playerName)}
                .map { $0.corpIdentity })
            let factionInfoFlat = factionInfo.flatMap({ $0 }).joined(separator: ": ")
            switch whichBox {
            case "A":
                idTextPlayerA.stringValue = factionInfoFlat
            case "B":
                idTextPlayerB.stringValue = factionInfoFlat
            default :
                print("WhichBox switch case A or B not found")
            }
        }
    }
}

// MARK: - Button actions

extension ViewController {
    
    // Toggle which player is runner and corp
    @IBAction func playerARadioButtonsClicked(_ sender: AnyObject) {
        
        if playerARunnerRadioButton.state == NSControl.StateValue.on {
            playerBCorpRadioButton.state = NSControl.StateValue.on
            playerBRunnerRadioButton.state = NSControl.StateValue.off
            updatefactionInfoFromName(playerName: comboBoxPlayerA.stringValue, whichBox: "A", playingAsRunner: true)
            updatefactionInfoFromName(playerName: comboBoxPlayerB.stringValue, whichBox: "B", playingAsRunner: false)
        } else {
            playerBRunnerRadioButton.state = NSControl.StateValue.on
            updatefactionInfoFromName(playerName: comboBoxPlayerB.stringValue, whichBox: "B", playingAsRunner: true)
            updatefactionInfoFromName(playerName: comboBoxPlayerA.stringValue, whichBox: "A", playingAsRunner: false)
        }
    }
    
    @IBAction func playerBRadioButtonsClicked(_ sender: AnyObject) {
        
        if playerBRunnerRadioButton.state == NSControl.StateValue.on {
            playerACorpRadioButton.state = NSControl.StateValue.on
            playerARunnerRadioButton.state = NSControl.StateValue.off
            updatefactionInfoFromName(playerName: comboBoxPlayerB.stringValue, whichBox: "B", playingAsRunner: true)
            updatefactionInfoFromName(playerName: comboBoxPlayerA.stringValue, whichBox: "A", playingAsRunner: false)
        } else {
            playerARunnerRadioButton.state = NSControl.StateValue.on
            updatefactionInfoFromName(playerName: comboBoxPlayerA.stringValue, whichBox: "A", playingAsRunner: true)
            updatefactionInfoFromName(playerName: comboBoxPlayerB.stringValue, whichBox: "B", playingAsRunner: false)
        }
    }
    // Set the flatline output text when checkbox ticked for a player. Only one can be ticked at a time
    
    @IBAction func flatlinePlayerACheckBoxClicked(_ sender: Any) {
        
        if playerAFlatlineWinCheckBox.state == NSControl.StateValue.on {
            playerBFlatlineWinCheckBox.state = NSControl.StateValue.off
            writeToOutputFile(content: " ", fileName: fileFlatlinedA)
            writeToOutputFile(content: " ", fileName: fileWinB)
            writeToOutputFile(content: "Flatlined", fileName: fileFlatlinedB)
            writeToOutputFile(content: "WIN", fileName: fileWinA)
        } else {
            writeToOutputFile(content: " ", fileName: fileFlatlinedB)
            writeToOutputFile(content: " ", fileName: fileWinA)
        }
    }
    
    @IBAction func flatlinePlayerBCheckBoxClicked(_ sender: Any) {
        
        if playerBFlatlineWinCheckBox.state == NSControl.StateValue.on {
            playerAFlatlineWinCheckBox.state = NSControl.StateValue.off
            writeToOutputFile(content: " ", fileName: fileFlatlinedB)
            writeToOutputFile(content: " ", fileName: fileWinA)
            writeToOutputFile(content: "Flatlined", fileName: fileFlatlinedA)
            writeToOutputFile(content: "WIN", fileName: fileWinB)
        } else {
            writeToOutputFile(content: " ", fileName: fileFlatlinedA)
            writeToOutputFile(content: " ", fileName: fileWinB)
        }
    }
    
    // Update OBS via text file outputs
    
    @IBAction func updateButtonClicked(_ sender: Any) {
        
        writeToOutputFile(content: comboBoxPlayerA.stringValue, fileName: fileNameA)
        writeToOutputFile(content: comboBoxPlayerB.stringValue, fileName: fileNameB)
        
        writeToOutputFile(content: String(playerAscore.score), fileName: fileScoreA)
        writeToOutputFile(content: String(playerBscore.score), fileName: fileScoreB)
        
        writeToOutputFile(content: idTextPlayerA.stringValue, fileName: fileIDTextA)
        writeToOutputFile(content: idTextPlayerB.stringValue, fileName: fileIDTextB)
    }
    
    // Locate and import NTRM.json file
    
    @IBAction func locateNRTMjsonButtonClicked(_ sender: Any) {
        
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSFileHandlingPanelOKButton {
                self.selectedInputFile = panel.url
            }
        }
    }
    
    // Maniplulate scores
    
    @IBAction func increaseButtonClickedA(_ sender: Any) {
        
        playerAscore.increment()
        scoreTextPlayerA.stringValue = String(playerAscore.score)
        writeToOutputFile(content: String(playerAscore.score), fileName: fileScoreA)
        if playerAscore.isSevenPlus() {
            writeToOutputFile(content: "WIN", fileName: fileWinA)
        }
    }
    
    @IBAction func increaseButtonClickedB(_ sender: Any) {
        
        playerBscore.increment()
        scoreTextPlayerB.stringValue = String(playerBscore.score)
        writeToOutputFile(content: String(playerBscore.score), fileName: fileScoreB)
        if playerBscore.isSevenPlus() {
            writeToOutputFile(content: "WIN", fileName: fileWinB)
        }
    }
    
    @IBAction func decreaseButtonClickedA(_ sender: Any) {
        
        playerAscore.decrement()
        scoreTextPlayerA.stringValue = String(playerAscore.score)
        writeToOutputFile(content: String(playerAscore.score), fileName: fileScoreA)
    }
    
    @IBAction func decreaseButtonClickedB(_ sender: Any) {
        
        playerBscore.decrement()
        scoreTextPlayerB.stringValue = String(playerBscore.score)
        writeToOutputFile(content: String(playerBscore.score), fileName: fileScoreB)
    }
    
    @IBAction func resetScoresButtonClicked(_ sender: Any) {
        
        playerAscore.reset()
        playerBscore.reset()
        
        scoreTextPlayerA.stringValue = "0"
        scoreTextPlayerB.stringValue = "0"
        
        writeToOutputFile(content: "0", fileName: fileScoreA)
        writeToOutputFile(content: "0", fileName: fileScoreB)
        
        writeToOutputFile(content: " ", fileName: fileWinA)
        writeToOutputFile(content: " ", fileName: fileWinB)
        
        writeToOutputFile(content: " ", fileName: fileFlatlinedA)
        writeToOutputFile(content: " ", fileName: fileFlatlinedB)
        
        playerAFlatlineWinCheckBox.state = NSControl.StateValue.off
        playerBFlatlineWinCheckBox.state = NSControl.StateValue.off
    }
}
