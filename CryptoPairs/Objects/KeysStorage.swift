//
//  KeysStorage.swift
//  CryptoPairs
//
//  Created by hadevs on 11.04.2023.
//

import Foundation
import Security

typealias Key = KeyGenerator.Output

struct KeysStorage {
    
    private var defaultQuery: [String: Any] {
        [ kSecClass as String: kSecClassGenericPassword,
          kSecAttrAccount as String: "com.crypto.pairs"]
    }
    
    func fetchKeys() -> [Key] {
        var keychainQuery: [String: Any] = defaultQuery
        keychainQuery[kSecReturnData as String] = true
        keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne

        var retrievedData: AnyObject?
        _ = SecItemCopyMatching(keychainQuery as CFDictionary, &retrievedData)
        
        guard let retrievedData = retrievedData as? Data else {
            return []
        }
        
        let retrievedArray = (try? JSONSerialization.jsonObject(with: retrievedData, options: []) as? [[String: Any]]) ?? []
        let keys = retrievedArray.compactMap { try? Key(from: $0) }
        return keys
    }
    
    func contains(key: Key) -> Bool {
        fetchKeys().firstIndex(of: key) != nil
    }
    
    func add(key: Key) throws {
        var fetched = fetchKeys()
        fetched.append(key)
        try update(fetched: fetched)
    }
    
    func remove(key: Key) throws {
        var fetched = fetchKeys()
        fetched = fetched.filter { $0 != key }
        try update(fetched: fetched)
    }
    
    private func update(fetched: [Key]) throws {
        let arr = fetched.compactMap { $0.dictionary }
        let data = try JSONSerialization.data(withJSONObject: arr, options: [])
        
        var writeQuery: [String: Any] = defaultQuery
        writeQuery[kSecValueData as String] = data

        SecItemDelete(writeQuery as CFDictionary)
        SecItemAdd(writeQuery as CFDictionary, nil)
    }
}
