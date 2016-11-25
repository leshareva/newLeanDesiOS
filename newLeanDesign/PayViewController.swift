//
//  PayViewController.swift
//  Lean Design
//
//  Created by Sladkikh Alexey on 11/15/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import DigitsKit
import Swiftstraints
import Caishen

class PayViewController: UIViewController, CardTextFieldDelegate,  {
    @IBOutlet weak var cardTextField: CardTextField?
    
    override func viewDidLoad() {
        cardTextField?.cardTextFieldDelegate = self
        
    }
    
    func cardTextField(_ cardTextField: CardTextField, didEnterCardInformation information: Card, withValidationResult validationResult: CardValidationResult) {
        // A valid card has been entered, if information is not nil and validationResult == CardValidationResult.Valid
    }
    
    func cardTextFieldShouldShowAccessoryImage(_ cardTextField: CardTextField) -> UIImage? {
        
    }
    
    func cardTextFieldShouldProvideAccessoryAction(_ cardTextField: CardTextField) -> (() -> ())? {
        // You can return a callback function which will be called if a user tapped on cardTextField's accessory button
        // If you return nil, cardTextField won't display an accessory button at all.
    }


}
