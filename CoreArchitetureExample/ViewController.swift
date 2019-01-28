//
//  ViewController.swift
//  CoreArchitetureExample
//
//  Created by EquipeSuporteAplicacao on 2/14/18.
//  Copyright © 2018 EquipeSuporteAplicacao. All rights reserved.
//
//

import CoreArchitecture
import UIKit

struct LoginState : State{
    var isLoading : Bool
    var hasError : NSError?
}

enum LoginAction : Action{
    case login(user : String, pass : String)
}

class loginComponent: Component<LoginState> {
    override func process(_ action: Action) {
        
        guard let action = action as? LoginAction else { return }
        
        switch action {
            case .login(user: let user, pass: let pass): self.login(user: user, pass: pass)
        }
    }
    
    private func login(user : String, pass : String){
        var state = self.state
        
        state.isLoading = true
        state.hasError = nil
        
        self.commit(state)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            var state = self.state
            
            state.isLoading =  false
            //state.hasError = NSError(domain: "x", code: 100, userInfo: nil)
            
            let navigation = BasicNavigation.present(self, from: self)
            
            self.commit(state, navigation)
        })
    }
}

class ViewController: UIViewController{
    
    let component  = loginComponent(state: LoginState(isLoading: false, hasError: nil))
    let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    var core : Core!
    
    @IBOutlet weak var txtUser: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configViewController()
        
        self.core = Core(rootComponent: component)
        component.subscribe(self)
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func enter(_ sender: UIButton){
        if let user = self.txtUser.text, let pass = self.txtPass.text{
            if !user.isEmpty && !pass.isEmpty{
                self.core.dispatch(LoginAction.login(user: user, pass: pass))
            }
        }
    }
    
    private func showTestViewController(){
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "teste")
        self.present(VC, animated: true, completion: nil)
    }
    
    private func configViewController(){
        self.indicator.center = self.view.center
        self.indicator.activityIndicatorViewStyle = .whiteLarge
        self.indicator.backgroundColor = UIColor.darkGray
        self.view.addSubview(indicator)
    }
}

extension ViewController : Subscriber{
    func update(with state: LoginState) {
        
        if state.isLoading{
            self.indicator.startAnimating()
        }else{
            self.indicator.stopAnimating()
        }
        
        if state.hasError != nil{
            let alert = UIAlertController(title: "Atenção", message: "Erro", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    typealias StateType = LoginState
    
    func perform(_ navigation: Navigation) {
        
        guard let navigation = navigation as? BasicNavigation else { return }
        
        switch navigation {
        case .present(let _, from: let _):
            self.showTestViewController()
        case .push(_, _):
            print("x")
        case .pop(_):
            print("x")
        case .dismiss(_):
            print("x")
        }
        
    }
}
