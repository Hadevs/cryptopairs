//
//  CryptoKeyGenerator.swift
//  CryptoPairs
//
//  Created by hadevs on 11.04.2023.
//

import CryptoSwift

struct CryptoKeyGenerator {
    struct Output {
        var cryptokey: Array<UInt8>
        var salt: Array<UInt8>
    }
    
    func generate(password: String) throws -> Output {
        let passwordBytes = Array(password.utf8)
        let salt: Array<UInt8> = AES.randomIV(AES.blockSize)
        let cryptoKey = try Scrypt(password: passwordBytes, salt: salt, dkLen: 32, N: 2048, r: 8, p: 1).calculate()
        return .init(cryptokey: cryptoKey, salt: salt)
    }
}
