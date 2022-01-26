//
//  TextFieldTableViewCell.swift
//  testUpax-David-Guillermo-Lopez-Vazquez
//
//  Created by David Lopez on 1/25/22.
//

import UIKit

protocol EnableFormDelegate: AnyObject {
    func enableForm(enable: Bool)
}

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate, TextFieldUserNameDelegate {
    
    static let identifier = "TextFieldTableViewCell"
    
    @IBOutlet weak var textField_: UITextField!
    weak var enableFormDelegate: EnableFormDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        textField_.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == textField_ {
            let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
            let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
            let typedCharacterSet = CharacterSet(charactersIn: string)
            let alphabet = allowedCharacterSet.isSuperset(of: typedCharacterSet)
            enableFormDelegate?.enableForm(enable: true)
            return alphabet
            
        } else {
            enableFormDelegate?.enableForm(enable: false)
            return false
        }
    }
    
    func getUserName() -> String? {
        return textField_.text
    }
}
