//
//  ViewController.swift
//  JCS-Calculator
//
//  Created by James Slusser on 05/10/17.
//  Copyright © 2017 James Slusser. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    @IBOutlet weak var memory: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if !(digit == "." && textCurrentlyInDisplay.contains(".")) {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = (digit == ".") ? "0." : digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displays: (result: Double?, isPending: Bool, description: String) {
        get {
            return (Double(display.text!)!, false, history.text!)
        }
        set {
            if newValue.result != nil {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.usesGroupingSeparator = false
                numberFormatter.maximumFractionDigits = Constants.numberOfDigitsAfterDecimalPoint
                display.text = numberFormatter.string(from: NSNumber(value: newValue.result!))
            }
            if newValue.description.isEmpty {
                history.text = " "
            } else {
                history.text = newValue.description + (newValue.isPending ? ( (newValue.description.characters.last != " ") ? " …" : "…") : " =")
            }
            if let memoryValue = dictionary["M"] {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.usesGroupingSeparator = false
                numberFormatter.maximumFractionDigits = Constants.numberOfDigitsAfterDecimalPoint
                memory.text = numberFormatter.string(from: NSNumber(value: memoryValue))
            } else {
                memory.text = " "
            }
        }
    }
    
    private var brain = CalculatorBrain()
    private var dictionary = [String: Double]()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displays.result!)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displays = brain.evaluate(using: dictionary)
    }
    
    
    
    @IBAction func clear(_ sender: UIButton) {
        brain = CalculatorBrain()
        dictionary = [:]
        displays = (0, false, "")
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            var textCurrentlyInDisplay = display.text!
            textCurrentlyInDisplay.remove(at: textCurrentlyInDisplay.index(before: textCurrentlyInDisplay.endIndex))
            if textCurrentlyInDisplay.isEmpty {
                userIsInTheMiddleOfTyping = false
                textCurrentlyInDisplay = "0"
            }
            display.text = textCurrentlyInDisplay
        } else {
            brain.undo()
            displays = brain.evaluate(using: dictionary)
        }
    }
    
    
    @IBAction func evaluateVariable(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = String(sender.currentTitle!.characters.dropFirst())
        dictionary[symbol] = displays.result!
        displays = brain.evaluate(using: dictionary)
    }
    

    @IBAction func setVariable(_ sender: UIButton) {
        let symbol = sender.currentTitle!
        brain.setOperand(variable: symbol)
        displays = brain.evaluate(using: dictionary)
    }
}

