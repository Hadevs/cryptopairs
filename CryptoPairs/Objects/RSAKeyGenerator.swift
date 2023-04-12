//
//  RSAKeyGenerator.swift
//  CryptoPairs
//
//  Created by hadevs on 11.04.2023.
//

import CryptoSwift

struct RSAKeyGenerator {
    struct Output {
        var publicKey: Array<UInt8> = .init()
        var privateKey: Array<UInt8> = .init()
    }
    
    
    func generate() throws  -> Output {
        let rsa = try RSA(n: 2048, e: 3)
        let privateKey = (try rsa.externalRepresentation()).bytes
        let publicKey = (try rsa.publicKeyExternalRepresentation()).bytes
        return .init(publicKey: publicKey, privateKey: privateKey)
    }
}
