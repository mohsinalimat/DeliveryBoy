//
//  MapViewController.swift
//  Delivery Boy
//
//  Created by RSTI E-Services on 31/08/17.
//  Copyright © 2017 RSTI E-Services. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation


class MapViewController: UIViewController, CLLocationManagerDelegate {
var locationManager = CLLocationManager()
var mapView = GMSMapView()
 var destinationlocation : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 28.459274, longitude: 77.0702305)

    override func viewDidLoad() {
        super.viewDidLoad()
        
              
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: 350, height: 450), camera: GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 13))
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.setAllGesturesEnabled(true)
        mapView.settings.compassButton = true
        let mapInsets = UIEdgeInsets(top: 80.0, left: 0.0, bottom: 0.0, right: 0.0)
        mapView.padding = mapInsets
        
        
        
        //so the mapView is of width 200, height 200 and its center is same as center of the self.view
        mapView.center = self.view.center
        self.view.addSubview(mapView)
        
        
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        // marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "My Location"
        marker.snippet = "Task 2"
        marker.map = mapView
       marker.position = (locationManager.location?.coordinate)!
        let DestinationMarker = GMSMarker()
        DestinationMarker.position = destinationlocation
        DestinationMarker.snippet = "Delivery Location"
        DestinationMarker.title = "Huda Metro Station"
        DestinationMarker.map = mapView
     //   DestinationMarker.icon = #imageLiteral(resourceName: "destinationMarker")
        
        let bounds = GMSCoordinateBounds()
        bounds.includingCoordinate(destinationlocation)
        bounds.includingCoordinate((locationManager.location?.coordinate)!)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
        mapView.animate(with: update)
        mapView.moveCamera(update)
        mapView.settings.compassButton = true
        
       
       // let destination = "\("28.4542691"),\("77.0459559")"
        self.getPolylineRoute(from: (locationManager.location?.coordinate)!, to: destinationlocation)
        
        
    
        
        // Do any additional setup after loading the view.
    }
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
      //  let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving&key=AIzaSyAxj931MVcUeUCY4oJh-DZ7GI1_SLZtNGY")!
        var urlString = "\("https://maps.googleapis.com/maps/api/directions/json")?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&key=\("AIzaSyAxj931MVcUeUCY4oJh-DZ7GI1_SLZtNGY")"
        urlString = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
        let url2 = URL(string: urlString)

        
        let task = session.dataTask(with: url2!, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        let routes  = json["routes"] as? [Any]
                        if (routes?.count)! > 0 {
                            let overview_polyline : NSDictionary = routes?[0] as! NSDictionary
                            
                            
                            let polyString = overview_polyline.value(forKeyPath: "overview_polyline.points")
                            
                            
                            //Call this method to draw path on map
                            self.showPath(polyStr: polyString as! String)

                        }
                        else {
                            print("No Routes Found")
                        }
                        
                    }
                    
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    func showPath(polyStr :String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.map = mapView // Your map view
        polyline.strokeColor = UIColor.darkGray
        
            }
    
    @IBAction func StartNavigation(_ sender: UIButton) {
        
        let testURL = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(destinationlocation.latitude),\(destinationlocation.longitude)&directionsmode=driving")!
        UIApplication.shared.openURL(testURL)
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
