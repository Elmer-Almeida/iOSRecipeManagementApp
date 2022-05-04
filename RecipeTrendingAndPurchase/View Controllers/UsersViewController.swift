//
//  UsersViewController.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-18.
//

import UIKit

class UsersViewController: UIViewController {
    
    // create table view
    let tableView: UITableView = UITableView()
    
    // safe area guide
    var safeAreaGuide: UILayoutGuide!
    
    // maindelegate access
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // unwind to users view controller
    @IBAction func unwindToUsersViewController(sender: UIStoryboardSegue) {}
    
    // connect navigation bar
    @IBOutlet var navigationBar: UINavigationBar!
    
    // TODO: THIS IS A TEMPORARY MEASURE TO DELETE THE DATABASE FILE FOR TESTING PURPOSES
    @IBAction func deleteMyDatabaseFile() {
        mainDelegate.deleteMyDatabaseFile()
    }
    
    @IBAction func doneButtonTapped(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        safeAreaGuide = view.layoutMarginsGuide
        
        view.backgroundColor = mainDelegate.hexStringToUIColor(hex: "#f7f4fb")
        self.tableView.backgroundColor = mainDelegate.hexStringToUIColor(hex: "f7f4fb")
        
        // configure navigation bar
        configureNavigationBar()
        
        // configure table view to display users
        configureTableView()
        
        // only load API data for USERS if the API data is not loaded (ie. usersList < 8)
        if self.mainDelegate.usersList.count < 8 {
            let usersFunction = { (fetchedUsers: [UserAPIObject]) in
                DispatchQueue.main.async {
                    self.insertUsersAPIDataIntoUsersTable(usersAPIList: fetchedUsers)
                    // reload the table view data
                    self.tableView.reloadData()
                }
            }
            UserAPI.shared.fetchUsersList(onCompletion: usersFunction)
        }
    }
    
    // insert API users into database
    func insertUsersAPIDataIntoUsersTable(usersAPIList: [UserAPIObject]) {
        for item in usersAPIList {
            let newUserObj: User = User.init()
            newUserObj.initWithData(theID: item.id, theFirstName: item.firstName, theLastName: item.lastName, theEmail: item.email, theImage: item.img)
            
            let returnCode = self.mainDelegate.insertIntoUsersTable(user: newUserObj)
            
            if returnCode {
                print("All users were added to the database successfully.")
            }
        }
        print("the usersList has \(mainDelegate.usersList.count)")
    }
    
    func configureNavigationBar() {
        navigationBar?.topItem?.title = "All Users"
    }
    
    // config table view
    func configureTableView() {
        view.addSubview(tableView)
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "user_cell")
        tableView.dataSource = self
        tableView.delegate = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: navigationBar!.bottomAnchor, constant: 1).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor, constant: -5.0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainDelegate.usersList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user_cell", for: indexPath)
        
        // conform UITableViewCell (cell) to RecipeTableViewCell
        guard let userCell = cell as? UserTableViewCell else {
            return cell
        }
        
        let userItem = mainDelegate.usersList[indexPath.row]
        
        // check if recipe img is a URL
        if let userImageURL = URL(string: userItem.img!) {
            // add the recipe img from the url to the UIImageView
            userCell.imageViewItem.loadImage(from: userImageURL)
        }
         
        // set the rest of the properties for each tableView cell (UserTableViewCell)
        userCell.userNameLabel.text = "\(userItem.firstName!) \(userItem.lastName!)"
        userCell.userEmailLabel.text = userItem.email
        userCell.userRecipeCountLabel.text = "\(String(mainDelegate.getCountOfRecipes(forUserID: userItem.id!))) recipes contributed"
        
        userCell.accessoryType = .disclosureIndicator
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainDelegate.selectedUserForRecipesList = mainDelegate.usersList[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "UsersViewToUsersRecipeViewSegue", sender: nil)
    }
}
