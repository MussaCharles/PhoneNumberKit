//
//  PhoneNumberKit.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation
import CoreTelephony

public class PhoneNumberKit : NSObject {
    
    // MARK: Lifecycle
    public static let sharedInstance = PhoneNumberKit()
    
    var metadata: [MetadataTerritory] = []

    override init() {
        super.init()
        metadata = populateMetadata()
    }
    
    deinit {
        metadata = []
    }
    
    // MARK: Data population
    
    // Populate the metadata from the json file
    func populateMetadata() -> [MetadataTerritory] {
        var territoryArray : [MetadataTerritory] = [MetadataTerritory]()
        let frameworkBundle = NSBundle(forClass: PhoneNumberKit.self)
        let jsonPath = frameworkBundle.pathForResource("PhoneNumberMetadata", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        do {
            let jsonObjects : NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            let metaDataDict : NSDictionary = jsonObjects["phoneNumberMetadata"] as! NSDictionary
            let metaDataTerritories : NSDictionary = metaDataDict["territories"] as! NSDictionary
            let metaDataTerritoryArray : NSArray = metaDataTerritories["territory"] as! NSArray
            for territory in metaDataTerritoryArray {
                let parsedTerritory = MetadataTerritory(jsondDict: territory as! NSDictionary)
                territoryArray.append(parsedTerritory)
            }
        }
        catch {
            
        }
        return territoryArray
    }
    
    // MARK: Country and region code
    
    // Get a list of all the countries in the metadata database
    public func allCountries() -> [String] {
        let results = metadata.map{$0.codeID}
        return results
    }
    
    // Get the countries corresponding to a given country code
    public func countriesForCode(code: UInt64) -> [String] {
        let results = metadata.filter { $0.countryCode == code}
            .map{$0.codeID}
        return results
    }
    
    // Get the main country corresponding to a given country code
    public func mainCountryForCode(code: UInt64) -> String? {
        let results = metadata.filter { $0.countryCode == code}
        if (results.count > 0) {
            var mainResult : MetadataTerritory
            if (results.count > 1) {
                mainResult = results.filter { $0.mainCountryForCode == true}.first!
            }
            else {
                mainResult = results.first!
            }
            return mainResult.codeID
        }
        return nil
    }

    
    // Get a the country code for a specific country
    public func codeForCountry(country: NSString) -> UInt64? {
        let results = metadata.filter { $0.codeID == country.uppercaseString}
            .map{$0.countryCode}
        return results.first
    }
    
    // Get the user's default region code, based on the carrier and if not available, the device region
    public func defaultRegionCode() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        if (carrier != nil && (carrier!.isoCountryCode != nil)) {
            return carrier!.isoCountryCode!.uppercaseString;
        } else {
            let currentLocale = NSLocale.currentLocale()
            let countryCode : String = currentLocale.objectForKey(NSLocaleCountryCode) as! String
            return countryCode.uppercaseString;
        }
    }

    
}

