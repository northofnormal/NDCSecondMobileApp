//
//  RandomlyShowing.swift
//  NDCSecondMobileApp
//
//  Created by Anne Cahalan on 6/12/18.
//  Copyright © 2018 Anne Cahalan. All rights reserved.
//

import Foundation
import UIKit

protocol RandomlyShowing {
    
    var randomizerLabel: UILabel! { get set }
    
}

extension RandomlyShowing {
    
    func setRandomizerResultsLabel(with divisor: UInt32) {
        if shouldShow(divisor: divisor) {
            randomizerLabel.text = "The random number was divisible by \(divisor)"
        } else {
            randomizerLabel.text = "The random number was not divisible by \(divisor)"
        }
    }
    
    func shouldShow(divisor: UInt32) -> Bool {
        let number = arc4random_uniform(101)
        return number % divisor == 0
    }
}
