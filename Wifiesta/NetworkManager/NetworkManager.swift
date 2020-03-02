//
//  NetworkManager.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 28/01/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    //Itunes Media search api call
    static func callItunesMediaSearcherApi(searchUrl: String, completionBlock: @escaping(_ info: Any?, _ status: ApiResponseCase)-> Void){
        let urlString = searchUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print(urlString as Any)
        Alamofire.request(urlString!).responseJSON { (response) in
            parseApiRespnse(response: response) { (info, status) in
                completionBlock(info, status)
            }
        }
        
    }
    
    //Parse response into Model by JsonDecoder
    static func parseApiRespnse(response: DataResponse<Any> , completionBlock: @escaping(_ info: Any?, _ status: ApiResponseCase)-> Void) {
        if response.result.isSuccess{
            guard let _ = response.result.value as? [String: Any] else {
                completionBlock(nil, .failure)
                return
            }
            guard let data = response.data, !data.isEmpty else{
                completionBlock(nil, .failure)
                return
            }
            do {
                //here dataResponse received from a network request
                let decoder = JSONDecoder()
                let model = try decoder.decode(ArtistModel.self, from:
                    response.data!) //Decode JSON Response Data
                completionBlock(model, .success)
            } catch let parsingError {
                print("Error", parsingError)
                completionBlock(nil, .failure)
            }
        }else{
            completionBlock(nil, .failure)
        }
        
    }
}
