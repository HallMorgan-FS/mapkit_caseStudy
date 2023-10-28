//
//  ContentView.swift
//  MyMapkitPractice
//
//  Created by Morgan Hall on 10/27/23.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var directions: [String] = []
    @State private var showDirections = false
    
    var body: some View {
        VStack {
            //add a map view and bind the directions
            MapView(directions: $directions)
            
            //Under the map, add a button so the user can see directions
            Button(action: {
                //Display a sheet that shows the directions
                self.showDirections.toggle()
            }, label: {
                Text("Show directions")
            })
            .disabled(directions.isEmpty)
            .padding()
        }.sheet(isPresented: $showDirections, content: {
            VStack {
                Text("Directions")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                //Add a divider
                Divider().background(Color.blue)
                
                //Use a list that will show the actual directions
                List {
                    ForEach(0..<self.directions.count, id: \.self){ i in
                        Text(self.directions[i]).padding()
                    }
                }
            }
        })
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    //Define a directions property inside the mapview
    @Binding var directions: [String]
    
    //Implement the make coordinator function
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    
    //Implement the makeUIView func
    func makeUIView(context: Context) -> MKMapView {
        //This is the function that provides the view we want to display in the UIViewRepresentable
        
        //Create an empty mapview
        let mapview = MKMapView()
        //Set the mapview delegate
        mapview.delegate = context.coordinator
        
        //Create an MKCoordinateRegion to center the mapview on a specific region
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.71, longitude: -74), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        
        //Set the region on the map
        mapview.setRegion(region, animated: true)
        
        //Create a placemark for NYC
        let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.71, longitude: -74))
        //Create a placemark for Boston
        let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.36, longitude: -71.05))
        
        //Create an MK Directions request
        let request = MKDirections.Request()
        //Set the source
        request.source = MKMapItem(placemark: p1)
        //Set the destination
        request.destination = MKMapItem(placemark: p2)
        //Set the transport type
        request.transportType = .automobile
        
        //Now that we have the request object, we need to create a directions object and calculate the directions
        
        let directions = MKDirections(request: request)
        
        //Call the calculate function
        directions.calculate { response, error in
            //The response object will have a list of routes that we are calculting.
            //Grab the list of routes
            guard let route = response?.routes.first else {return}
            
            //Add some annotations to the map to mark the two places
            mapview.addAnnotations([p1, p2])
            //add an overlat to draw the route line
            mapview.addOverlay(route.polyline)
            //Set the region
            mapview.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
            
            //get the directions from nyc and boston and place them in the directions array
            self.directions = route.steps.map { $0.instructions }.filter{ !$0.isEmpty }
            
        }
        
        //return the mapview
        return mapview
    }
    
    //Implement updateUIView func
    func updateUIView(_ uiView: MKMapView, context: Context) {
    }
    
    class MapViewCoordinator : NSObject, MKMapViewDelegate {
        
        //Implement the function that draws the route line
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            //Create the renderer that will render the polyline overlay we need inside of our map
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
    }
}
