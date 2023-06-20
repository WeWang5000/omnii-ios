//
//  KeychainItem.swift
//  omnii
//
//  Created by huyang on 2023/4/26.
//

import Foundation

public struct KeychainItem {
    // MARK: Types
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError
    }
    
    // MARK: Properties
    
    private static let defaultServeive: String = "com.social.omnii"
    
    let service: String
    
    private(set) var account: String
    
    let accessGroup: String?
    
    // MARK: Intialization
    
    init(account: String, accessGroup: String? = nil) {
        self.init(service: KeychainItem.defaultServeive, account: account, accessGroup: accessGroup)
    }
    
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    // MARK: Keychain access
    
    func readItem() throws -> String {
        /*
         Build a query to find the item that matches the service, account and
         access group.
         */
        var query = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError }
        
        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                throw KeychainError.unexpectedPasswordData
        }
        
        return password
    }
    
    func saveItem(_ password: String) throws {
        // Encode the password into an Data object.
        let encodedPassword = password.data(using: String.Encoding.utf8)!
        
        do {
            // Check for an existing item in the keychain.
            try _ = readItem()
            
            // Update the existing item with the new password.
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
            
            let query = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError }
        } catch KeychainError.noPassword {
            /*
             No password was found in the keychain. Create a dictionary to save
             as a new keychain item.
             */
            var newItem = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            
            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError }
        }
    }
    
    func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError }
    }
    
    // MARK: Convenience
    
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
    
}

// MARK: - convenient methods

public extension KeychainItem {
    
    static func save(key: String, value: String) {
        do {
            try KeychainItem(account: key).saveItem(value)
        } catch {
            print("Unable to save \(key) to keychain.")
        }
    }
    
    static func value(for key: String) -> String? {
        do {
            let value = try KeychainItem(account: key).readItem()
            return value
        } catch {
            print("Unable to get \(key) from keychain.")
            return nil
        }
    }
    
    static func delete(key: String) {
        do {
            try KeychainItem(account: key).deleteItem()
        } catch {
            print("Unable to delete \(key) from keychain")
        }
    }
    
}

// MARK: - userID

public extension KeychainItem {
    
    // MARK: - apple
    static var currentAppleUserIdentifier: String? {
        guard let storedIdentifier = KeychainItem.value(for: "AppleUserIdentifier") else { return nil }
        return storedIdentifier
    }
    
    static func saveAppleUserIdentifier(_ identifier: String) {
        KeychainItem.save(key: "AppleUserIdentifier", value: identifier)
    }
    
    static func deleteAppleUserIdentifierFromKeychain() {
        KeychainItem.delete(key: "AppleUserIdentifier")
    }
    
    // MARK: - moblie
    static var currentUserIdentifier: String? {
        guard let storedIdentifier = KeychainItem.value(for: "MoblieUserIdentifier") else { return nil }
        return storedIdentifier
    }
    
    static func saveUserIdentifier(_ identifier: String) {
        KeychainItem.save(key: "MoblieUserIdentifier", value: identifier)
    }
    
    static func deleteUserIdentifierFromKeychain() {
        KeychainItem.delete(key: "MoblieUserIdentifier")
    }
    
}
