//
//  KeyViewController.swift
//  CryptoPairs
//
//  Created by hadevs on 11.04.2023.
//

import UIKit

class KeyViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var copyButton: UIButton!
    private var key: Key?
    
    convenience init(key: Key) {
        self.init()
        self.key = key
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        copyButton.layer.cornerRadius = 12
        imageView.image = generateQRCode(from: key?.publicKey ?? "")
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    @IBAction private func copyButtonAction() {
        UIPasteboard.general.string = key?.privateKey
        copyButton.setTitle("Copied!", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.copyButton.setTitle("Copy private key", for: .normal)
        }
    }
}
