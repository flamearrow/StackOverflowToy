//
//  User.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import Foundation

struct User: Codable, Identifiable, Hashable {
    let user_id: Int
    var id: Int { user_id }
    
    let badge_counts: BadgeCounts
    let account_id: Int
    let is_employee: Bool
    let last_modified_date: Int
    let last_access_date: Int
    let reputation_change_year: Int
    let reputation_change_quarter: Int
    let reputation_change_month: Int
    let reputation_change_week: Int
    let reputation_change_day: Int
    let reputation: Int
    let creation_date: Int
    let user_type: String
    let accept_rate: Int?
    let location: String?
    let website_url: String?
    let link: String
    let profile_image: String
    let display_name: String
    
    struct BadgeCounts: Codable, Identifiable, Hashable {
        let bronze: Int
        let silver: Int
        let gold: Int
        
        var id: Self { self }
    }
}

extension User {
    static let testUser1 = User(
        user_id: 22656,
        badge_counts: BadgeCounts(
            bronze: 9328,
            silver: 9287,
            gold: 888
        ),
        account_id: 11683,
        is_employee: false,
        last_modified_date: 1742663401,
        last_access_date: 1742645451,
        reputation_change_year: 8966,
        reputation_change_quarter: 8966,
        reputation_change_month: 2013,
        reputation_change_week: 648,
        reputation_change_day: -40,
        reputation: 1504871,
        creation_date: 1222430705,
        user_type: "registered",
        accept_rate: 86,
        location: "Reading, United Kingdom",
        website_url: "http://csharpindepth.com",
        link: "https://stackoverflow.com/users/22656/jon-skeet",
        profile_image: "https://www.gravatar.com/avatar/6d8ebb117e8d83d74ea95fbdd0f87e13?s=256&d=identicon&r=PG",
        display_name: "Jon Skeet"
    )
    
    static let testUser2 = User(
        user_id: 6309,
        badge_counts: BadgeCounts(
            bronze: 5601,
            silver: 4726,
            gold: 563
        ),
        account_id: 4243,
        is_employee: false,
        last_modified_date: 1742648723,
        last_access_date: 1742652560,
        reputation_change_year: 13491,
        reputation_change_quarter: 13491,
        reputation_change_month: 3491,
        reputation_change_week: 1082,
        reputation_change_day: 40,
        reputation: 1331263,
        creation_date: 1221344553,
        user_type: "registered",
        accept_rate: 100,
        location: "France",
        website_url: "https://devstory.fyi/vonc",
        link: "https://stackoverflow.com/users/6309/vonc",
        profile_image: "https://i.sstatic.net/I4fiW.jpg?s=256",
        display_name: "VonC"
    )
    
    static let testUser3 = User(
        user_id: 1144035,
        badge_counts: BadgeCounts(
            bronze: 846,
            silver: 693,
            gold: 61
        ),
        account_id: 1165580,
        is_employee: false,
        last_modified_date: 1741043106,
        last_access_date: 1740844622,
        reputation_change_year: 3208,
        reputation_change_quarter: 3208,
        reputation_change_month: 788,
        reputation_change_week: 250,
        reputation_change_day: 10,
        reputation: 1271511,
        creation_date: 1326311637,
        user_type: "registered",
        accept_rate: nil,
        location: "New York, United States",
        website_url: "http://www.data-miners.com",
        link: "https://stackoverflow.com/users/1144035/gordon-linoff",
        profile_image: "https://www.gravatar.com/avatar/e514b017977ebf742a418cac697d8996?s=256&d=identicon&r=PG",
        display_name: "Gordon Linoff"
    )
    
    static let testUser4 = User(
        user_id: 22657,
        badge_counts: BadgeCounts(
            bronze: 9328,
            silver: 9287,
            gold: 888
        ),
        account_id: 11683,
        is_employee: false,
        last_modified_date: 1742663401,
        last_access_date: 1742645451,
        reputation_change_year: 8966,
        reputation_change_quarter: 8966,
        reputation_change_month: 2013,
        reputation_change_week: 648,
        reputation_change_day: -40,
        reputation: 1504871,
        creation_date: 1222430705,
        user_type: "registered",
        accept_rate: 86,
        location: "Reading, United Kingdom",
        website_url: "http://csharpindepth.com",
        link: "https://stackoverflow.com/users/22656/jon-skeet",
        profile_image: "https://1234",
        display_name: "Jon Skeet"
    )
}
