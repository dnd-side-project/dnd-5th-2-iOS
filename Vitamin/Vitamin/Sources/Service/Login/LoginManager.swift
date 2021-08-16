//
//  LoginManager.swift
//  Vitamin
//
//  Created by Jinhyang on 2021/08/06.
//

import Foundation
import Alamofire

class LoginManager {

  static let shared = LoginManager()

  let networkManager = NetworkManager.shared

  var currentUser: User?

  private init() { }

  /// 회원가입에 성공하면 로그인 요청
  /// completionHandler로 로그인 성공 여부를 전달
  func signup(user: User,
              completionHandler: @escaping (Bool) -> Void) {
    networkManager.requestSignUp(with: user) { success in
      self.login(loginUser: user) { success in
       completionHandler(success)
      }
    }
  }

  func login(loginUser: User,
             completionHandler: @escaping (Bool) -> Void) {
    networkManager.requestLogin(with: loginUser) { result in
      switch result {
      case .success(let loginResult):
        let successToCreate = TokenUtils.shared.create(value: loginResult.token)
        self.currentUser = loginResult.user
        completionHandler(successToCreate)
      case .failure(let error):
        print(error.localizedDescription)
        completionHandler(false)
      }
    }
  }

  func login(completionHandler: @escaping (Bool) -> Void) {
    guard let header = TokenUtils.shared.getAuthorizationHeader() else {
      completionHandler(false)
      return
    }

    networkManager.requestLogin(with: header) { result in
      switch result {
      case .success(let user):
        self.currentUser = user
        completionHandler(true)
      case .failure(let error):
        print(error.localizedDescription)
        completionHandler(false)
      }
    }
  }

  func checkEmailExists(email: String, completion: @escaping (Bool) -> Void) {
    networkManager.checkExists(feature: .emailCheck, parameterValue: email) { result in
      guard let result = result as? [String: Bool],
            let exists = result["exists"],
            exists else {
        completion(false)
        return
      }
      completion(true)
    }
  }

  func checkNickNameExists(nickName: String, completion: @escaping (Bool) -> Void) {
    networkManager.checkExists(feature: .usernameCheck, parameterValue: nickName) { result in
      guard let result = result as? [String: Bool],
            let exists = result["exists"],
            exists else {
        completion(false)
        return
      }
      completion(true)
    }
  }

  func logOut() {
    TokenUtils.shared.delete()
  }
}
