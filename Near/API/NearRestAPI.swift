//
//  NearRestAPI.swift
//  Near
//
//  Created by Bhushan Mahajan on 24/09/21.
//

import Foundation
import UIKit
import CoreMedia

class NearRestAPI {
    
    //MARK: - GET Requests
    
    //Get Account Balance Function
    //This Function is used to fetch the account balance for the current user.
    
    func getBalance(accountName: String, completion: @escaping (String) -> Void) {
        let url = "\(Constants.getBalanceURL.rawValue)\(accountName)"
        URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard error == nil, let data = data else {
                print("Something went wrong \(String(describing: error?.localizedDescription))")
                return
            }
            if let stringResponse = String(data: data, encoding: .utf8) {
                completion(stringResponse)
            }
        }.resume()
    }
    
    func getAccountActivity(accountName: String, completion: @escaping ([AccountActivity]) -> Void) {
        let url = "\(Constants.getAccountActivityURL.rawValue)\(accountName)/activity?limit=10"
        URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard error == nil, let data = data else {
                print("Something went wrong \(String(describing: error?.localizedDescription))")
                return
            }
            var result: [AccountActivity]?
            do {
                result = try JSONDecoder().decode([AccountActivity].self, from: data)
            } catch {
                print("Error Converting data!!")
            }
            guard let json = result else {
                return
            }
            completion(json)
        }.resume()
    }
    
    //MARK: - POST Requests
    
    //Create User Function
    //This Function is called when the user want to create a account.
    
    func createUser(username: String, completion: @escaping (Result<CreateAccountModel, Error>) -> Void) {
        
        //Url for the rest api server for creating account
        guard let url = URL(string: Constants.createUserURL.rawValue) else { return }
        
        //Post Request with content type, body and the account name parameter.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //Body
        let body: [String: Any] = [
            "name": username
        ]
        
        do {
            //Converting the body into JSON readable format by JSONSerializaion.
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch let error {
            completion(.failure(error))
        }
        
        // Hitting the rest api server with the request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error as! Error))
                return
            }
            
            //Using the swift object that is in folder Model->NearAPIDataModel
            var success: CreateAccountModel?
            
            //Converting the response from the server into json readable format.
            if let data = data {
                do {
                    
                    //Decoding the json into a swift object and mapping it to a swift object for easier acces in code.
                    success = try JSONDecoder().decode(CreateAccountModel.self, from: data)
                    guard let json = success else { return }
                    
                    //Returning back the json as swift object.
                    completion(.success(json))
                } catch let error {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    //Sign In Function
    //This function is called when the user wants to sign in to his/her account.
    
    func signInUser(passPhrase: String, completion: @escaping (Result<SignInModel, Error>) -> Void) {
        
        //Url for the rest api server for signin to account.
        guard let url = URL(string: Constants.signInUserURL.rawValue
        ) else { return }
        
        //Post Request with content type, body and the account name parameter.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //Body
        let body: [String: Any] = [
            "seed_phrase": passPhrase
        ]
        
        do {
            //Converting the body into JSON readable format by JSONSerializaion.
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch let error {
            completion(.failure(error.localizedDescription as! Error))
        }
        
        // Hitting the rest api server with the request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error as! Error))
                return
            }
            
            //Using the swift object that is in folder Model->NearAPIDataModel
            var success: SignInModel?
            
            //Converting the response from the server into json readable format.
            if let data = data {
                do {
                    
                    //Decoding the json into a swift object and mapping it to a swift object for easier acces in code.
                    success = try JSONDecoder().decode(SignInModel.self, from: data)
                    guard let json = success else { return }
                    //Returning back the json as swift object.
                    completion(.success(json))
                } catch let error {
                    completion(.failure(error as! Error))
                }
            }
        }.resume()
    }
    
    //TransactionStatus Function
    //This function is called when the user wants to view his/her account transactions and recent activity.
    
    func transactionStatus(accountName: String, hash: String, completion: @escaping (Bool) -> Void) {
        
        //Url for the rest api server for getting the recent transaction details for account.
        guard let url = URL(string: Constants.transactionStatusURL.rawValue) else { return }
        
        //Post Request with content type, body and the accountName and hash parameter.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //Body
        let body: [String: Any] = [
            "jsonrpc":"2.0",
            "id":"dontcare",
            "method":"tx",
            "params": [hash, accountName]
        ]
        
        do {
            //Converting the body into JSON readable format by JSONSerializaion.
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch let error {
            print("Error occured while parsing the body! \(error.localizedDescription)")
        }
        
        // Hitting the rest api server with the request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Something went wrong!! \(String(describing: error?.localizedDescription))")
                return
            }
            
            //Converting the response from the server into json readable format.
            if let data = data {
                do {
                    
                    //Decoding and checking for successfull status of transaction.
                    let success = try? JSONDecoder().decode(TransactionResponse.self, from: data)
                    if let success = success {
                        if success.successfull == nil {
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                } catch let error {
                    print("Error in parsing data!! \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    //ViewUserWatchHistory Function
    //This function is called when users watch history for videos has to be checked.
    
    func viewUserWatchHistory(accountName: String, videoId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        //Url for the rest api server for getting the watch history for the user.
        guard let url = URL(string: Constants.viewUserWatchHistoryURL.rawValue) else { return }
        
        //Post Request with content type, body and the accountName and hash parameter.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //Body
        let body: [String: Any] = [
            "account_id": accountName,
            "contract":"headstraitdev2.testnet",
            "method":"checkUserVideoWatchHistory",
            "params": [ "mainAccount": "headstraitdev2.testnet", "videoId": videoId ]
        ]
        do {
            //Converting the body into JSON readable format by JSONSerializaion.
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch let error {
            completion(.failure(error.localizedDescription as! Error))
        }
        // Hitting the rest api server with the request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error as! Error))
                return
            }
            //Converting the response from the server into Boolean format
            if let stringResponse = String(data: data!, encoding: .utf8) {
                let bool = Bool(stringResponse)
                completion(.success(bool!))
            }
        }.resume()
    }
    
    //SaveUserVideoDetails
    //This function is called when we have to save the users watch history for the video user has watched recently.
    
    func saveUserVideoDetails(accountName: String, videoId: String, privateKey: String, completion: @escaping (Bool) -> Void) {
        //Url for the rest api server for saving the watch history.
        guard let url = URL(string: Constants.saveVideoDetailsAndSendTokenURL.rawValue) else { return }
        //Post Request with content type, body and the accountName and videoID parameter.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //Body
        let body: [String: Any] = [
            "account_id": accountName,
            "private_key": privateKey,
            "contract":"headstraitdev2.testnet",
            "method":"saveUserVideoDetails",
            "params":["mainAccount":"headstraitdev2.testnet","videoId": videoId]
        ]
        do {
            //Converting the body into JSON readable format by JSONSerializaion.
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch let error {
            print("Error occured while parsing the body! \(error.localizedDescription)")
        }
        // Hitting the rest api server with the request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Something went wrong!! \(String(describing: error?.localizedDescription))")
                return
            }
            //Converting the response from the server into json readable format.
            if let data = data {
                do {
                    //Decoding the json and checking for successfull value.
                    let success = try? JSONDecoder().decode(SaveVideoDetailsAndSendToken.self, from: data)
                    if let success = success {
                        if success.successfull == nil {
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                } catch let error {
                    print("Error in parsing data!! \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    //SendNearToken Function
    //This function is used to send near tookens to the user after watching a video.
    
    func sendToken(accountName: String, videoId: String, privateKey: String, completion: @escaping (Bool) -> Void) {
        //URL for sending the token
        guard let url = URL(string: Constants.saveVideoDetailsAndSendTokenURL.rawValue) else { return }
        //Post Request with content type, body and the accountName and videoID parameter.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //Body
        let body: [String: Any] = [
            "account_id": accountName,
            "private_key": privateKey,
            "contract":"headstraitdev2.testnet",
            "method":"sendToken",
            "params":["yoctonearAsU128":"2","walletAddress": accountName]
        ]
        do {
            //Converting the body into JSON readable format by JSONSerializaion.
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch let error {
            print("Error occured while parsing the body! \(error.localizedDescription)")
        }
        // Hitting the rest api server with the request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Something went wrong!! \(String(describing: error?.localizedDescription))")
                return
            }
            //Converting the response from the server into json readable format.
            if let data = data {
                do {
                    //Decoding the json and checking for successfull value.
                    let success = try? JSONDecoder().decode(SaveVideoDetailsAndSendToken.self, from: data)
                    if let success = success {
                        if success.successfull == nil {
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                } catch let error {
                    print("Error in parsing data!! \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    //Generate Link Drop Function
    //This function is used to generate linkdrop in the app.
    
    func generateLinkDrop(accountName: String, amount: String, privateKey: String, completion: @escaping (Result<GenerateLinkDrop, Error>) -> Void) {
        //Url for the rest api server for generating link drop.
        guard let url = URL(string: Constants.generateLinkDropURL.rawValue) else { return }
        
        //Post Request with content type, body and the account name parameter.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //Body
        let body: [String: Any] = [
            "account_id": accountName,
            "private_key": privateKey,
            "contract": "testnet",
            "amount": amount
        ]
        do {
            //Converting the body into JSON readable format by JSONSerializaion.
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch let error {
            completion(.failure(error.localizedDescription as! Error))
        }
        // Hitting the rest api server with the request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error as! Error))
                return
            }
            //Converting the response from the server into json readable format.
            if let data = data {
                do {
                    //Decoding the json into a swift object and mapping it to a swift object for easier acces in code.
                    let success = try JSONDecoder().decode(GenerateLinkDrop.self, from: data)
                    //Returning back the json as swift object.
                    completion(.success(success))
                } catch let error {
                    completion(.failure(error as! Error))
                }
            }
        }.resume()
    }
    
    //Reclaim Near Function
    //This function is used to reclaim the near tokens used for generating link drop.
    
    func reclaimNear(accountName: String, secretKey: String, completion: @escaping (Bool) -> Void) {
        //Url for reclaiming near tokens used for generating link drop.
        guard let url = URL(string: Constants.saveVideoDetailsAndSendTokenURL.rawValue) else { return }
        //Post Request with content type, body and the accountName and videoID parameter.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //Body
        let body: [String: Any] = [
            "account_id":"testnet",
            "private_key":"ed25519:\(secretKey)",
            "contract":"testnet",
            "method":"claim",
            "params":["account_id": accountName]
        ]
        do {
            //Converting the body into JSON readable format by JSONSerializaion.
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch let error {
            print("Error occured while parsing the body! \(error.localizedDescription)")
        }
        // Hitting the rest api server with the request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Something went wrong!! \(String(describing: error?.localizedDescription))")
                return
            }
            //Converting the response from the server into json readable format.
            if let data = data {
                do {
                    //Decoding the json and checking for successfull value.
                    let success = try? JSONDecoder().decode(SaveVideoDetailsAndSendToken.self, from: data)
                    if let success = success {
                        if success.successfull == nil {
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                } catch let error {
                    print("Error in parsing data!! \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}