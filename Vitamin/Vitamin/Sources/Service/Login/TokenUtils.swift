//
//  TokenUtils.swift
//  Vitamin
//
//  Created by Jinhyang on 2021/08/07.
//

import Security
import Alamofire

class TokenUtils {

  static let shared = TokenUtils()

  private init() { }

  // MARK: - Todo 어떻게 bundleId 정할까?
  let service = Bundle.main.bundleIdentifier ?? "com.innie.Vitamin"

  func create(account: String, value: String) -> Bool {
    let keyChainQuery: NSDictionary = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecValueData: value.data(using: .utf8, allowLossyConversion: false)!
    ]

    SecItemDelete(keyChainQuery)
    return SecItemAdd(keyChainQuery, nil) == errSecSuccess
  }

  func read(account: String) -> String? {
    let KeyChainQuery: NSDictionary = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecReturnData: kCFBooleanTrue,
      kSecMatchLimit: kSecMatchLimitOne
    ]

    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(KeyChainQuery, &dataTypeRef)

    if status == errSecSuccess {
      let retrievedData = dataTypeRef as! Data
      let value = String(data: retrievedData, encoding: String.Encoding.utf8)
      return value
    } else {
      print("failed to loading, status code = \(status)")
      return nil
    }
  }

  func delete(account: String) {
    let keyChainQuery: NSDictionary = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account
    ]

    SecItemDelete(keyChainQuery)
  }

  func getAuthorizationHeader() -> HTTPHeaders? {
    if let accessToken = self.read(account: "accessToken") {
      return ["Authorization": "bearer \(accessToken)"] as HTTPHeaders
    } else {
      return nil
    }
  }
}
