//
//  WiFinderViewController.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 28/01/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import UIKit
import AVKit
import Alamofire

class WiFinderViewController: UIViewController {
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var noResultLabel: UILabel!
    var searchController: UISearchController!
    var selectedMediaType = MediaContentType.Music.rawValue
    var artistDataPayload: [ArtistSearchPayload]?
    var selectedArtistModel: ArtistSearchPayload?
    let mediaContentArray = [["title": "Music", "mediaType": MediaContentType.Music.rawValue], ["title": "TvShow", "mediaType": MediaContentType.TvShow.rawValue], ["title": "Movies", "mediaType": MediaContentType.Movie.rawValue]] // Set searchBar scope dictionary
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewProperties()
        loadSearchController()
        changeTableViewBackgroundColor()
    }
    
    func loadSearchController() { // Load searchController
        searchController = UISearchController(searchResultsController: nil)
        let scb = searchController.searchBar
        scb.scopeButtonTitles = mediaContentArray.map{$0["title"]!} // load scopeButton title
        scb.tintColor = UIColor.black
        scb.barTintColor = UIColor.clear
        if let textfield = scb.value(forKey: "searchField") as? UITextField {
            textfield.keyboardType = .asciiCapable
        }
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "Search artists"
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    func tableViewProperties() { // Set estimated row height
        searchTableView.estimatedRowHeight = 164
        searchTableView.rowHeight = UITableView.automaticDimension
    }
    
    func changeTableViewBackgroundColor() { // Update TableView background color
        if self.artistDataPayload?.isEmpty ?? true{
            self.searchTableView.backgroundColor = .white
        }else{
            self.searchTableView.backgroundColor = #colorLiteral(red: 0.8732705712, green: 0.8732910752, blue: 0.8732799888, alpha: 1)
        }
    }
    
}

// MARK: -
// MARK: -  UITableViewDataSource,UITableViewDelegate
extension WiFinderViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistDataPayload?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WifiestaConstant.artistCellIdentifier, for: indexPath) as! ArtistTableViewCell
        cell.loadDataOnCell(artistModel: artistDataPayload?[indexPath.row], mediaContentType: selectedMediaType) // Load artistModel into cell with selected media content type
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let artistModel = artistDataPayload?[indexPath.row]{
            selectedArtistModel = artistModel
            self.performSegue(withIdentifier: WifiestaConstant.playerControllerSegueIdentifier, sender: self) // Perform segue to load PlayerViewController
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == WifiestaConstant.playerControllerSegueIdentifier{
            let playerViewController = segue.destination as! PlayerViewController
            playerViewController.artistModel = selectedArtistModel // Passing selected artist model info
            playerViewController.mediaType = selectedMediaType // Passing selected media content type
        }
    }
}

// MARK: -
// MARK: - UISearchBarDelegate
extension WiFinderViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if mediaContentArray.count > selectedScope{
            selectedMediaType = mediaContentArray[selectedScope]["mediaType"] ?? "" // Set media type like Music, movies etc.
            callItunesMediaSearchApi(searchString: searchBar.text) // Call itunes search api on searchbar scope button selection
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateUIOnEmptySearchAndNoInternet() // update tableview when search cancel button pressed
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        callItunesMediaSearchApi(searchString: searchBar.text) //Call itunes search api on search button clicked
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{ // update tableview when searchText become empty
            updateUIOnEmptySearchAndNoInternet()
        }
    }
}

// MARK: -
// MARK: - Itunes Media Search API
extension WiFinderViewController{
    
    func callItunesMediaSearchApi(searchString: String?) {
        if isNetWorkReachable() { // Checking internet connectivity
            if let searchString = searchString, !searchString.isEmpty{ // Check searchString is valid or not
                self.searchTableView.isHidden = true
                self.noResultLabel.isHidden = true
                activityLoader.startAnimating()
                let urlString = String(format: WifiestaConstant.mediaSearcherUrlString, searchString, selectedMediaType) // Generate urlString with media type
                NetworkManager.callItunesMediaSearcherApi(searchUrl: urlString){ [weak self] (info, status) in // Calling Itunes Media search api
                    if status == .success{
                        if let responseInfo = info{
                            let artistSearchResponse = responseInfo as! ArtistModel
                            self?.artistDataPayload = artistSearchResponse.results // Assign response into artistPayload
                        }
                    }
                    self?.updateUI() // Update tableview as per the api response
                }
            }else{
                CommonUtility.showAlertMessage(messageString: WifiestaConstant.emptySearchField, controller: self) // Alert on empty SearchText
                updateUIOnEmptySearchAndNoInternet()
            }
        }else{
            CommonUtility.showAlertMessage(messageString: WifiestaConstant.noInternetConnection, controller: self) // // Alert on no internet connection
            updateUIOnEmptySearchAndNoInternet()
        }
    }
    
}

extension WiFinderViewController{
    
    func isNetWorkReachable() -> Bool { // Check if network is available
        return NetworkReachabilityManager()!.isReachable
    }
    
    func updateUIOnEmptySearchAndNoInternet() { // Reload tableview when no internet and search available
        self.artistDataPayload?.removeAll()
        DispatchQueue.main.async {
            self.changeTableViewBackgroundColor()
            self.noResultLabel.text = ""
            self.noResultLabel.isHidden = true
            self.activityLoader.stopAnimating()
            self.searchTableView.reloadData()
        }
    }
    func updateUI() { // Reload tableview when reponse data present or not.
        DispatchQueue.main.async {
            if self.artistDataPayload?.isEmpty ?? true{
                self.searchTableView.isHidden = true
                self.noResultLabel.isHidden = false
                self.noResultLabel.text = WifiestaConstant.noDataFound
            }else{
                self.searchTableView.isHidden = false
                self.noResultLabel.isHidden = true
                self.noResultLabel.text = ""
            }
            self.activityLoader.stopAnimating()
            self.changeTableViewBackgroundColor()
            self.searchTableView.reloadData()
        }
    }
    
    func showAlertOnNoConnection() { // Show no internet connection alert
        CommonUtility.showAlertMessage(messageString: WifiestaConstant.noInternetConnection, controller: self)
    }
}
