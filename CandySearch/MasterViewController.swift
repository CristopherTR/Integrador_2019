import UIKit
import Alamofire
import SwiftyJSON


class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  // MARK: - Properties
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchFooter: SearchFooter!
  
    var detailViewController: DetailViewController? = nil
    var candies = [Candy]()
    var filteredCandies = [Candy]()
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar usuario"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        
        searchController.searchBar.scopeButtonTitles = ["Todo", "Especialidad", "Salud", "Otro"]
        searchController.searchBar.delegate = self
        
        
        tableView.tableFooterView = searchFooter
        
        DispatchQueue.main.async {
            Alamofire.request("https://jsonplaceholder.typicode.com/todos", method: .get, encoding: JSONEncoding.default).responseJSON { (response: DataResponse<Any>) in
                
            switch(response.result) {
                case.success(let data):
                    let json = JSON(data)
                    let title = json [0]["title"].stringValue
                    print(title)
                case .failure(_):
                    print("error")
                }
            }
    }
        
        candies = [
            Candy(name:"Josimar",lastName:"Tantahuilca", degree:"Diseñador", health:"Saludable"),
            Candy(name:"Cristopher",lastName:"Torres", degree:"Desarrollador", health:"Saludable"),
            Candy(name:"Grover",lastName:"Lazaro", degree:"Analista", health:"Enfermo"),
            Candy(name:"Jean",lastName:"Ferrer", degree:"Diseñador", health:"Enfermo")]
        
        
            
            /*
            { response in
            print("Request: \(response.request)")
            print("Response: \(response.response)")
            print("Error: \(response.error)")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
        }*/
        
        if let splitViewController = splitViewController {
            let controllers = splitViewController.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if splitViewController!.isCollapsed {
            if let selectionIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectionIndexPath, animated: animated)
            }
        }
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredCandies.count, of: candies.count)
            return filteredCandies.count
        }
        
        searchFooter.setNotFiltering()
        return candies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let candy: Candy
        if isFiltering() {
            candy = filteredCandies[indexPath.row]
        } else {
            candy = candies[indexPath.row]
        }
        cell.textLabel!.text = candy.name
        cell.detailTextLabel!.text = candy.lastName
        return cell
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let candy: Candy
                if isFiltering() {
                    candy = filteredCandies[indexPath.row]
                } else {
                    candy = candies[indexPath.row]
                }
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailCandy = candy
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Private instance methods
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Todo") {
        filteredCandies = candies.filter({( candy : Candy) -> Bool in
            let doesDegreeMatch = (scope == "Especialidad") || (candy.degree == scope)
            
            if searchBarIsEmpty() {
                return doesDegreeMatch
            } else {
                return doesDegreeMatch && candy.degree.lowercased().contains(searchText.lowercased())
            }
        })
        tableView.reloadData()
    }
    
    func filterContentForSearchText2(_ searchText2: String, scope2: String = "Todo") {
        filteredCandies = candies.filter({( candy : Candy) -> Bool in
            let doesHealthMatch = (scope2 == "Salud") || (candy.health == scope2)
            
            if searchBarIsEmpty() {
                return doesHealthMatch
            } else {
                return doesHealthMatch && candy.health.lowercased().contains(searchText2.lowercased())
            }
        })
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

extension MasterViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    func searchBar2(_ searchBar2: UISearchBar, selectedScopeButtonIndexDidChange selectedScope2: Int) {
        filterContentForSearchText2(searchBar2.text!, scope2: searchBar2.scopeButtonTitles![selectedScope2])
    }
}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    func updateSearchResults2(for searchController2: UISearchController) {
        let searchBar2 = searchController2.searchBar
        let scope2 = searchBar2.scopeButtonTitles![searchBar2.selectedScopeButtonIndex]
        filterContentForSearchText2(searchController2.searchBar.text!, scope2: scope2)
    }
}

