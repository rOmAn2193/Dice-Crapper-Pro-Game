//
//  GameVC.swift
//  Dice Crapper Pro
//
//  Created by Roman on 1/15/16.
//  Copyright © 2016 Roman Puzey. All rights reserved.
//

import UIKit
import AVFoundation

class GameVC: UIViewController, AVAudioPlayerDelegate
{
    var audioPlayer : AVAudioPlayer?

    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var lDice: UIImageView!
    @IBOutlet weak var rDice: UIImageView!
    @IBOutlet weak var startNewButton: UIButton!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var chip: UIImageView!
    @IBOutlet weak var roll: UIButton!
    @IBOutlet weak var toPoint: UIButton!
    @IBOutlet weak var addChipsPic: UIButton!
    @IBOutlet weak var bet: UILabel!

    var defaults = NSUserDefaults.standardUserDefaults()

    var currentChipBalance : Int?
    var currentBet : Int! = 250
    var total = Int!()
    var total2 = Int!()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if let chipBalance = defaults.stringForKey("currentChipBalance")
        {
            currentChipBalance = Int(chipBalance)
            defaults.synchronize()
        }

        if currentChipBalance == nil || currentChipBalance < 250
        {
            addChipsPic.hidden = false
            status.hidden = false
            status.text = "You need more chips to play, press the red chip in the top right to get some."
            roll.hidden = true
            toPoint.hidden = true
        }
        else
        {
            balance.text = defaults.stringForKey("currentChipBalance")
            currentChipBalance = Int(defaults.stringForKey("currentChipBalance")!)
            defaults.synchronize()
            roll.hidden = false
            
        }
    }

    @IBAction func addChips(sender: AnyObject)
    {
        defaults.setObject(100000, forKey: "currentChipBalance")

        balance.text = defaults.stringForKey("currentChipBalance")

        currentChipBalance = Int(defaults.stringForKey("currentChipBalance")!)

        defaults.synchronize()

        addChipsPic.hidden = true

        status.hidden = true
        roll.hidden = false

        do
        {
            try playSound("tapped", fileExtension: "mp3")
        }
        catch
        {
            print("Could not play file tapped.mp3")
            return
        }
    }

    @IBAction func newGame(sender: AnyObject)
    {
        result.hidden = true
        status.hidden = true

        lDice.image = UIImage(named: "dice06")
        rDice.image = UIImage(named: "dice06")

        roll.hidden = false
        toPoint.hidden = true
        startNewButton.hidden = true

        do
        {
            try playSound("tapped", fileExtension: "mp3")
        }
        catch
        {
            print("Could not play file tapped.mp3")
            return
        }
    }

    @IBAction func stepperChanged(sender: UIStepper)
    {
        do
        {
            try playSound("tapped", fileExtension: "mp3")
        }
        catch
        {
            print("Could not play file tapped.mp3")
            return
        }

        // set bet text and chip image to match stepper value
        bet.text = Int(stepper.value).description
        currentBet = Int(stepper.value)

        // change images based on stepper value

        switch stepper.value
        {
        case 50:
            chip.image = UIImage(named: "chip01")
        case 100:
            chip.image = UIImage(named: "chip02")
        case 150:
            chip.image = UIImage(named: "chip03")
        case 200:
            chip.image = UIImage(named: "chip04")
        case 250:
            chip.image = UIImage(named: "chip05")
        default:
            break
        }
    }

    @IBAction func rollTapped(sender: AnyObject)
    {
        if currentChipBalance == nil || currentChipBalance < 250
        {
            addChipsPic.hidden = false
            status.hidden = false
            status.text = "You need more chips to play, press the red chip in the top right to get some!"
            roll.hidden = true
            toPoint.hidden = true
        }
        else
        {
            do
            {
                try playSound("roll", fileExtension: "mp3")
            }
            catch
            {
                print("The sound roll has failed")
                return
            }

            // get point total and set images

            total = rollDiceForValue()

            // evaluate results of the first roll
            switch total
            {
            case 2, 3, 12:
                result.hidden = false
                result.text = "YOU LOSE!"
                result.textColor = UIColor.redColor()
                status.hidden = false
                status.text = "You rolled a \(total), that's Craps! and you lose. That was quick!"
                roll.hidden = true
                startNewButton.hidden = false

                do
                {
                    try playSound("lose", fileExtension: "mp3")
                }
                catch
                {
                    print("The sound lose.mp3 has failed to play")
                    return
                }

                currentChipBalance = currentChipBalance! - currentBet!

                defaults.setObject(currentChipBalance, forKey: "currentChipBalance")
                balance.text = defaults.stringForKey("currentChipBalance")
                defaults.synchronize()

            case 7, 11:
                result.hidden = false
                result.text = "YOU WIN!"
                result.textColor = UIColor.greenColor()
                status.hidden = false
                status.text = "You rolled a natural \(total), you win!!!"
                roll.hidden = true
                startNewButton.hidden = false

                do
                {
                    try playSound("win", fileExtension: "mp3")
                }
                catch
                {
                    print("The sound win.mp3 has failed to play")
                    return
                }

                currentChipBalance = currentChipBalance! + (currentBet! * 2)
                defaults.setObject(currentChipBalance, forKey: "currentChipBalance")
                balance.text = defaults.stringForKey("currentChipBalance")
                defaults.synchronize()

            case 4, 5, 6, 8, 9, 10:
                result.hidden = false
                result.text = "THAT'S POINT!!!"
                status.hidden = false
                status.text = "You rolled a \(total). Now you must roll another \(total) before rolling a 7 to win!"
                roll.hidden = true

                // show the to point button / phase two of game

                toPoint.hidden = false

                do
                {
                    try playSound("tapped", fileExtension: "mp3")
                }
                catch
                {
                    print("The sound tapped.mp3 has failed to play")
                    return
                }

                currentChipBalance = currentChipBalance! - currentBet!
                defaults.setObject(currentChipBalance, forKey: "currentChipBalance")
                balance.text = defaults.stringForKey("currentChipBalance")
                defaults.synchronize()

            default:
                break
            }
        }
    }

    @IBAction func toPointTapped(sender: AnyObject)
    {
        if currentChipBalance == nil || currentChipBalance < 250
        {
            addChipsPic.hidden = false
            status.hidden = false
            status.text = "You need more chips to play, press the red chip in the top right to get some!"
            roll.hidden = true
            toPoint.hidden = true
        }
        else
        {
            // get point totals and set images
            total2 = rollDiceForValue()
            let pointToMatch = self.total

            switch total2
            {
            case pointToMatch:
                result.hidden = false
                result.text = "YOU WIN!!!"
                result.textColor = UIColor.greenColor()
                status.hidden = false
                status.text = "You rolled a matching \(pointToMatch) for the win!!!"
                toPoint.hidden = true
                startNewButton.hidden = false

                do
                {
                    try playSound("win", fileExtension: "mp3")
                }
                catch
                {
                    print("The sound win.mp3 has failed to play")
                    return
                }

                currentChipBalance = currentChipBalance! + (currentBet! * 2)
                defaults.setObject(currentChipBalance, forKey: "currentChipBalance")
                balance.text = defaults.stringForKey("currentChipBalance")
                defaults.synchronize()

            case 7:
                result.hidden = false
                result.text = "YOU LOSE!"
                result.textColor = UIColor.redColor()
                status.hidden = false
                status.text = "You landed on a 7 before rolling the match point \(pointToMatch). You lose!"
                toPoint.hidden = true
                startNewButton.hidden = false
                do {
                    try playSound("lose", fileExtension: "mp3")
                } catch {
                    return
                }

                let defaults = self.defaults
                currentChipBalance = currentChipBalance! - currentBet!
                defaults.setObject(currentChipBalance, forKey: "currentChipBalance")
                balance.text = defaults.stringForKey("currentChipBalance")
                defaults.synchronize()

            default:
                result.hidden = false
                result.text = "Keep Rolling!"
                result.textColor = UIColor.grayColor()
                status.hidden = false
                status.text = "Win by rolling a \(pointToMatch) before rolling a losing 7."
                do {
                    try playSound("tapped", fileExtension: "mp3")
                } catch {
                    return
                }

                let defaults = self.defaults
                currentChipBalance = currentChipBalance! - currentBet!
                defaults.setObject(currentChipBalance, forKey: "currentChipBalance")
                balance.text = defaults.stringForKey("currentChipBalance")
                defaults.synchronize()

            }
        }
    }

    func rollDiceForValue() -> Int
    {
        var lDiceValue = Int(arc4random_uniform(UInt32(6)))
        var rDiceValue = Int(arc4random_uniform(UInt32(6)))
        let total = lDiceValue + rDiceValue + 2

        switch lDiceValue
        {
        case 0:
            lDice.image = UIImage(named: "dice01")
            lDiceValue++
        case 1:
            lDice.image = UIImage(named: "dice02")
            lDiceValue++
        case 2:
            lDice.image = UIImage(named: "dice03")
            lDiceValue++
        case 3:
            lDice.image = UIImage(named: "dice04")
            lDiceValue++
        case 4:
            lDice.image = UIImage(named: "dice05")
            lDiceValue++
        case 5:
            lDice.image = UIImage(named: "dice06")
            lDiceValue++
        default:
            break
        }

        switch rDiceValue
        {
        case 0...5:
            rDice.image = UIImage(named: "dice02\(rDiceValue + 1)")
            rDiceValue++
        default:
            break
        }

        return total
    }

    func playSound(fileName: String, fileExtension: String) throws {
        super.viewDidLoad()

        let dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

        dispatch_async(dispatchQueue, { let mainBundle = NSBundle.mainBundle()

            let filePath = mainBundle.pathForResource("\(fileName)", ofType:"\(fileExtension)")

            if let path = filePath{
                let fileData = NSData(contentsOfFile: path)

                do {
                    /* Start the audio player */
                    self.audioPlayer = try AVAudioPlayer(data: fileData!)

                    guard let player : AVAudioPlayer? = self.audioPlayer else {
                        return
                    }

                    /* Set the delegate and start playing */
                    player!.delegate = self
                    if player!.prepareToPlay() && player!.play() {
                        /* Successfully started playing */
                    } else {
                        /* Failed to play */
                    }

                } catch {
                    //self.audioPlayer = nil
                    return
                }

            }

        })

    }

}
