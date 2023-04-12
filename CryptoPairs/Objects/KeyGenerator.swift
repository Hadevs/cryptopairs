//
//  KeyGenerator.swift
//  CryptoPairs
//
//  Created by hadevs on 11.04.2023.
//

import Foundation
import CryptoSwift

struct KeyGenerator {
    enum OutputStep {
        case rsaKey
        case cryptoKey
        case done(Output)
    }
    
    enum OutputError: LocalizedError {
        case rsaKeygenFailed
        case cryptoKeygenFailed
        case privateKeyFailed
        
        var errorDescription: String? {
            switch self {
            case .privateKeyFailed: return "Private key generation failed."
            case .cryptoKeygenFailed: return "Crypto key generation failed."
            case .rsaKeygenFailed: return "RSA keys generation failed."
            }
        }
    }
    
    struct Output: Codable {
        var publicKey: String
        var privateKey: String
        
        var publicKeyFormatted: String {
            "-----BEGIN RSA PUBLIC KEY-----\n" + publicKey + "\n-----END RSA PUBLIC KEY-----"
        }
    }
    
    typealias ClosureOutput = Result<OutputStep, OutputError>
    func startGenerating(with password: String, closure: @escaping (ClosureOutput) -> ()) {
        func feedback(with result: ClosureOutput) {
            DispatchQueue.main.async {
                closure(result)
            }
        }
        
        DispatchQueue.global(qos: .utility).async {
            guard let rsaKeys = try? RSAKeyGenerator().generate() else {
                feedback(with: .failure(OutputError.rsaKeygenFailed))
                return
            }
            
            feedback(with: .success(.rsaKey))
            
            guard let cryptoKeys = try? CryptoKeyGenerator().generate(password: password) else {
                feedback(with: .failure(OutputError.cryptoKeygenFailed))
                return
            }
            
            feedback(with: .success(.cryptoKey))
            
            guard let privateKey = try? PrivateKeyGenerator().generate(salt: cryptoKeys.salt,
                                                            cryptokey: cryptoKeys.cryptokey,
                                                            privateKey: rsaKeys.privateKey,
                                                            publicKey: rsaKeys.publicKey) else {
                feedback(with: .failure(OutputError.privateKeyFailed))
                return
            }
            
            
            feedback(with: .success(
                            .done(
                                .init(publicKey: privateKey.publicKeyBase64, privateKey: privateKey.privateKeyBase64)
                            ))
            )
            
            return
        }
    }
}

extension Key: Equatable {
    static func == (lhs: Key, rhs: Key) -> Bool {
        lhs.publicKey == rhs.publicKey && lhs.privateKey == rhs.privateKey
    }
}
