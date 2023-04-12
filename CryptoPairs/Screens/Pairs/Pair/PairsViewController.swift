//
//  PairsViewController.swift
//  CryptoPairs
//
//  Created by Danil Kovalev on 10.04.2023.
//

import UIKit
import CryptoSwift

class PairsViewController: UIViewController {
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var tableView: UITableView!
    
    private let keyGenerator = KeyGenerator()
    private let keyStorage = KeysStorage()
    private var keys: [Key] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My keys"
        addAddButton()
        addLeftButton()
        setDelegates()
        reloadData()
    }
    
    private func setDelegates() {
        tableView.register(KeyTableViewCell.nib, forCellReuseIdentifier: KeyTableViewCell.nibName)
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func addAddButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
        navigationItem.setRightBarButton(addButton, animated: true)
    }
    
    private func addLeftButton() {
        let leftButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(leftAction))
        navigationItem.setLeftBarButton(leftButton, animated: true)
    }
    
    @objc private func leftAction() {
        let alertController = UIAlertController(title: "Import new key",
                                                message: "Please, provide base64 private key representation.",
                                                preferredStyle: .alert)
        alertController.addTextField { field in
            field.placeholder = "private key base64"
        }
        
        alertController.addTextField { field in
            field.placeholder = "password"
        }
        
        alertController.addAction(.init(title: "Import", style: .default, handler: { [self] action in
            guard let firstTextField = alertController.textFields?[0] else {
                return
            }
            
            guard let secondTextField = alertController.textFields?[1] else {
                return
            }
            
            // подключить OpenSSL не успел.
        }))
        
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    

    
    @objc private func addButtonAction() {
        let alertController = UIAlertController(title: "Generate a new pair",
                                                message: "Please, provide and cofirm your password to start generation process.",
                                                preferredStyle: .alert)
        alertController.addTextField { field in
            field.placeholder = "Password"
        }
        
        alertController.addTextField { field in
            field.placeholder = "Confirm the password"
        }
        alertController.addAction(.init(title: "Create", style: .default, handler: { action in
            guard let firstTextField = alertController.textFields?[0],  let secondTextField = alertController.textFields?[1] else {
                return
            }
            let firstPass = firstTextField.text ?? ""
            let secondPass = secondTextField.text ?? ""
            
            if firstPass == secondPass {
                self.generateRSAKeys(password: firstPass, confirmPassword: secondPass)
            } else {
                self.show(error: ScreenError.passwordsUnmatched)
            }
        }))
        
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    
    func generateRSAKeys(password: String, confirmPassword: String) {
        guard password == confirmPassword else {
            return 
        }
        
        disableCreateButton()
        configureLoadingStateUI()
        keyGenerator.startGenerating(with: password) { [weak self] result in
            switch result {
            case .success(let step):
                self?.configureLoadingStateUI(by: step)
                switch step {
                    case .done(let key):
                    self?.addKeyAndUpdate(key)
                    self?.enableCreateButton()
                        
                    default: break
                }
                return
            case .failure(let error):
                self?.enableCreateButton()
                self?.show(error: error)
                return
            }
        }
    }
    
    private func addKeyAndUpdate(_ key: Key) {
        guard !keyStorage.contains(key: key) else {
            return
        }
        try? keyStorage.add(key: key)
        reloadData()
    }
    
    private func reloadData() {
        self.keys = keyStorage.fetchKeys()
        tableView.reloadData()
    }
    
    private func show(error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func disableCreateButton() {
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func enableCreateButton() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func configureLoadingStateUI(by step: KeyGenerator.OutputStep? = nil) {
        guard let step = step else {
            title = "Generating RSA keys..."
            progressView.setProgress(0.3, animated: true)
            return
        }
        
        switch step {
        case .rsaKey:
            progressView.setProgress(0.5, animated: true)
            title = "Generating Crypto key..."
        case .cryptoKey:
            progressView.setProgress(0.8, animated: true)
            title = "Generating results..."
        case .done(_):
            progressView.setProgress(1, animated: true)
            title = "Key generated."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.title = "My keys"
            self.progressView.setProgress(0, animated: true)
        }
    }
}

extension PairsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: KeyTableViewCell.nibName, for: indexPath) as! KeyTableViewCell
        let key = keys[indexPath.row]
        cell.configure(by: key)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let key = keys[indexPath.row]
        let vc = KeyViewController(key: key)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        55
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let key = keys[indexPath.row]
        try? keyStorage.remove(key: key)
        self.keys = keyStorage.fetchKeys()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension PairsViewController {
    enum ScreenError: LocalizedError {
        case passwordsUnmatched
        var errorDescription: String? {
            return "Passwords should be equal."
        }
    }
}
