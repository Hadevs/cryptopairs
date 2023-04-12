//
//  AESKeyGenerator.swift
//  CryptoPairs
//
//  Created by hadevs on 11.04.2023.
//

import CryptoSwift

struct PrivateKeyGenerator {
    struct Output {
        var privateKeyBase64: String
        var publicKeyBase64: String
    }
    
    func generate(salt: Array<UInt8>, cryptokey: Array<UInt8>, privateKey: Array<UInt8>, publicKey: Array<UInt8>) throws -> Output {
        let iv = AES.randomIV(AES.blockSize)
        let cbc = CBC(iv: iv)
        let cipherText = try AES(key: cryptokey, blockMode: cbc).encrypt(privateKey)

        let finalData: Array<UInt8> = salt + cipherText + iv

        return .init(privateKeyBase64: finalData.toBase64(),
                     publicKeyBase64: publicKey.toBase64())
    }
}
