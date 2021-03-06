//
//  TempVC.swift
//  Shlist
//
//  Created by Pavel Lyskov on 30.01.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class TempVC: UIViewController {
   
    @IBOutlet weak var roundText: UITextField!
    
    
    let disposedBag = DisposeBag()
    
//    lazy var textField = NumberTextField.newWithBounds(200)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        textField.minValue = 1
//
//        view.addSubview(textField)
//
//        textField.translatesAutoresizingMaskIntoConstraints = false
//
//        let constraints: [NSLayoutConstraint] = [
//            textField.widthAnchor.constraint(equalToConstant: 280),
//            textField.heightAnchor.constraint(equalToConstant: 44),
//            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60)
//        ]
//
//        NSLayoutConstraint.activate(constraints)
//
//        let tap = UITapGestureRecognizer(handler: {[weak self] _ in
//            self?.view.endEditing(true)
//        })
//
//        self.view.addGestureRecognizer(tap)
//
//
//
//        self.slider.rx.value.map {Int($0)}
//            .bind(to: self.textField.rx.currentValue)
//            .disposed(by: self.disposedBag)
//        textField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        roundText.becomeFirstResponder()
//        textField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        roundText.becomeFirstResponder()
//        textField.becomeFirstResponder()
    }
    
}
