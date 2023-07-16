//
//  GPXTrackSegment+MapKit.swift
//  AllTrexxTracker
//
//  Created by merlos on 20/09/14.
//

import Foundation
import UIKit
import MapKit
import CoreGPX

///
/// This extension adds some methods to work with MapKit
///
#if os(iOS)
extension GPXTrackSegment {
    
    /// Returns a MapKit polyline with the points of the segment.
    /// This polyline can be directly plotted on the map as an overlay
    public var overlay: MKPolyline {
        var coords: [CLLocationCoordinate2D] = self.trackPointsToCoordinates()
        let pl = MKPolyline(coordinates: &coords, count: coords.count)
        return pl
    }
}
#endif

extension GPXTrackSegment {
  
    /// Helper method to create the polyline. Returns the array of coordinates of the points
    /// that belong to this segment
    func trackPointsToCoordinates() -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        for point in self.points {
            coords.append(point.coordinate)
        }
        return coords
    }
    
    /// Calculates length in meters of the segment
    func length() -> CLLocationDistance {
        var length: CLLocationDistance = 0.0
        var distanceTwoPoints: CLLocationDistance
        // We need at least two points
        if self.points.count < 2 {
            return length
        }
        var prev: CLLocation? // Previous
        for point in self.points {
            let pt: CLLocation = CLLocation(latitude: Double(point.latitude!), longitude: Double(point.longitude!) )
            if prev == nil { // If first point => set it as previous and go for next
                prev = pt
                continue
            }
            distanceTwoPoints = pt.distance(from: prev!)
            length += distanceTwoPoints
            // Set current point as previous point
            prev = pt
        }
        return length
    }    
}
