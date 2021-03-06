//
//  DatePickerViewController.swift
//  ConcertFindr
//
//  Created by iGuest on 5/23/17.
//  Copyright © 2017 Derek Han. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DatePickerViewController: UIViewController {
    
    private var SongKickAPIKey = "HqtbfXIKRDQWYRLi"

    var cityName: String = ""
    var metroID: String = ""
    var pins = [ConcertPin]()

    @IBOutlet weak var StartDateInputField: UITextField!
    @IBOutlet weak var TermsAndConditionLabel: UILabel!
    
    @IBOutlet weak var noDateResultImage: UIImageView!
    
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    @IBOutlet weak var EndDateInputField: UITextField!
    @IBOutlet weak var gatheringConcerts: UIImageView!
    
    private var CityNameSegue: String = "CityNameSegue"
    private var MapViewSegue: String = "mapViewSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround() 
        
        noDateResultImage.isHidden = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.full
        
        // Set startdate to today
        StartDateInputField.text = dateFormatter.string(from: Date())
        
        // Set enddate to 7 days from today
        EndDateInputField.text = dateFormatter.string(from: (Calendar.current as NSCalendar).date(byAdding: .day, value: 7, to: Date(), options: [])!)
        
        loadingWheel.hidesWhenStopped = true
        loadingWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingWheel.center = view.center
        gatheringConcerts.isHidden = true
        // Add toolbar to uidatepicker input view
        addToolBar()
        
        TermsAndConditionLabel.isUserInteractionEnabled = true
        let TermsTap = UITapGestureRecognizer(target: self, action: #selector(DatePickerViewController.showTermsAndConditions))
        TermsAndConditionLabel.addGestureRecognizer(TermsTap)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        
        
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                SearchConcertsButton(self)
            case UISwipeGestureRecognizerDirection.up:
                showTermsAndConditions()
            case UISwipeGestureRecognizerDirection.right:
                performSegue(withIdentifier: CityNameSegue, sender: self)
            default:
                break
            }
        }
    }
    
    func showTermsAndConditions() {
        let popup : TermsAndConditionsViewController = self.storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionsStoryboard") as! TermsAndConditionsViewController
        let navigationController = UINavigationController(rootViewController: popup)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(navigationController, animated: true, completion: nil)
    }

    // borrowed from Aproov Mote
    func addToolBar() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.black
        toolBar.tintColor = UIColor(red:0.37, green:0.62, blue:0.62, alpha:1.0)
        toolBar.backgroundColor = UIColor(red:0.37, green:0.62, blue:0.62, alpha:1.0)
        
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(DatePickerViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
//        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        label.text = "Select a date"
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([textBtn,flexSpace,okBarBtn], animated: true)
        
        StartDateInputField.inputAccessoryView = toolBar
        EndDateInputField.inputAccessoryView = toolBar
    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        StartDateInputField.resignFirstResponder()
        EndDateInputField.resignFirstResponder()
    }
    
    @IBAction func StartDateEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action:  #selector(DatePickerViewController.StartDateSelected), for: UIControlEvents.valueChanged)
    }
    
    func StartDateSelected(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.full
        
        StartDateInputField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func EndDateEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.date = (Calendar.current as NSCalendar).date(byAdding: .day, value: 7, to: Date(), options: [])!
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action:  #selector(DatePickerViewController.EndDateSelected), for: UIControlEvents.valueChanged)
    }
    
    func EndDateSelected(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.full
        
        EndDateInputField.text = dateFormatter.string(from: sender.date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CityNameSegue {
            _ = segue.destination as! CityInputViewController
        } else if segue.identifier == MapViewSegue {
            let tabBarControllers = segue.destination as! UITabBarController
            let mapController = tabBarControllers.viewControllers?[0] as! MapViewController
            mapController.annotations = self.pins
        }
    }
    
    @IBAction func SearchConcertsButton(_ sender: Any) {
        noDateResultImage.isHidden = true
        gatheringConcerts.isHidden = false
        loadingWheel.startAnimating()
        
        let formatDateForAPIRequest = DateFormatter()
        formatDateForAPIRequest.dateFormat = "yyyy-MM-dd"
        let getDateFromString = DateFormatter()
        getDateFromString.dateFormat = "EEEE, MMM dd, yyyy"
        let startDate = formatDateForAPIRequest.string(from: getDateFromString.date(from: StartDateInputField.text!)!)
        let endDate = formatDateForAPIRequest.string(from: getDateFromString.date(from: EndDateInputField.text!)!)
        
        Alamofire.request("http://api.songkick.com/api/3.0/events.json?apikey=\(SongKickAPIKey)&location=sk%3A\(self.metroID)&min_date=\(startDate)&max_date=\(endDate)&per_page=50")
            .validate(statusCode: 200..<300)
            .validate(contentType:["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let retrievedData = response.data {
                        let json = JSON(data: retrievedData)
                        self.parseReceivedJSON(json: json)
                        self.performSegue(withIdentifier: self.MapViewSegue, sender: self)
                    }
                    sleep(4) // sleep for 4 seconds for dramatic loading wheel animation
                    self.gatheringConcerts.isHidden = true
                    self.loadingWheel.stopAnimating()
                case .failure( _):
                    self.gatheringConcerts.isHidden = true
                    self.loadingWheel.stopAnimating()
                    self.noDateResultImage.isHidden = false
                }
        };

    }
    
    func parseReceivedJSON(json: JSON) {
        let dateFromFormatter = DateFormatter()
        dateFromFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
        dateFromFormatter.dateFormat = "yyyy-MM-dd"
        let dateToFormatter = DateFormatter()
        dateToFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
        dateToFormatter.dateFormat = "EEE, MMM dd"
        
        let timeFromFormatter = DateFormatter()
        timeFromFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
        timeFromFormatter.dateFormat = "HH:mm:ss"
        let timeToFormatter = DateFormatter()
        timeToFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
        timeToFormatter.dateFormat = "h:mma z"
        for singleConcert in json["resultsPage"]["results"]["event"] {
            let parsedConcert = singleConcert.1

            //There are sometimes multiple artists
            var artistsArray = [String]()
            var listenURL = ""
            var artistID = ""
            for artist in parsedConcert["performance"] {
                artistsArray.append(String(describing: artist.1["displayName"]))
                if artist.1["billingIndex"] == 1 {
                    listenURL = String(describing: artist.1["artist"]["uri"])
                    artistID = String(describing: artist.1["artist"]["id"])
                }
                
            }
            var eventDate = String(describing: parsedConcert["start"]["date"])
            let theDate = dateFromFormatter.date(from: eventDate)
            eventDate = dateToFormatter.string(from: theDate!)
            
            var startTime = String(describing: parsedConcert["start"]["time"])
            if(startTime == "null") {
                startTime = "No given start time"
            } else {
                let theStartTime = timeFromFormatter.date(from: startTime)
                startTime = timeToFormatter.string(from: theStartTime!)
            }
            
            let ticketsURL = String(describing: parsedConcert["uri"])
            
            var ageRestriction = String(describing: parsedConcert["ageRestriction"])
            if (ageRestriction == "null") {
                ageRestriction = "No age restriction"
            }
            var venueName = String(describing: parsedConcert["venue"]["displayName"])
            if (venueName == "null") {
                venueName = "No venue name"
            }
            
            let latitude = Double(String(describing: parsedConcert["location"]["lat"]))
            let longitude = Double(String(describing:parsedConcert["location"]["lng"]))
            
            if (latitude != nil && longitude != nil) {
               pins.append(ConcertPin(artist: artistsArray, artistID: artistID, startTime: startTime, eventDate: eventDate, ageRestriction: ageRestriction, venueName: venueName, listenURL: listenURL, ticketsURL: ticketsURL, latitude: latitude!, longitude: longitude!))
            }
        }
    }
}
