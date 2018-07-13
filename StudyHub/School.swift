//
//  School.swift
//  StudyHub
//
//  Created by Dan Levy on 1/4/18.
//  Copyright © 2018 Dan Levy. All rights reserved.
//

import UIKit
import Firebase

class School {
    private var _city: String?
    private var _coordinates: GeoPoint?
    private var _countryCode: String?
    private var _name: String?
    private var _postalCode: String?
    private var _state: String?
    private var _ref: DocumentReference?
    
    init(city: String?, coordinates: GeoPoint?, countryCode: String?, name: String?, postalCode: String?, state: String?, ref: DocumentReference?) {
        self._city = city
        self._coordinates = coordinates
        self._countryCode = countryCode
        self._name = name
        self._postalCode = postalCode
        self._state = state
        self._ref = ref
    }
    
    func getCity() -> String? {
        return self._city
    }
    func getCoordinates() -> GeoPoint? {
        return self._coordinates
    }
    func getCountryCode() -> String? {
        return self._countryCode
    }
    func getName() -> String? {
        return self._name
    }
    func getPostalCode() -> String? {
        return self._postalCode
    }
    func getState() -> String? {
        return self._state
    }
    func getRef() -> DocumentReference? {
        return self._ref
    }
    
    func setCity(city: String) {
        self._city = city
    }
    func setCoordinates(coordinates: GeoPoint) {
        self._coordinates = coordinates
    }
    func setCountryCode(countryCode: String) {
        self._countryCode = countryCode
    }
    func setName(name: String) {
        self._name = name
    }
    func setPostalCode(postalCode: String) {
        self._postalCode = postalCode
    }
    func setState(state: String) {
        self._state = state
    }
    func setRef(ref: DocumentReference) {
        self._ref = ref
    }
}
