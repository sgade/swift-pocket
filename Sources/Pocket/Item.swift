//
//  Item.swift
//  Pocket
//
//  Created by Sören Gade on 28.10.21.
//


import Foundation


/// An item from the Pocket queue.
///
/// The documentation and item setup is taken from the [Pocket developer documentation](https://getpocket.com/developer/docs/v3/retrieve).
public struct Item: Codable {

    private enum CodingKeys: String, CodingKey {

        case id             = "item_id"
        case resolvedId     = "resolved_id"
        case givenUrl       = "given_url"
        case resolvedUrl    = "resolved_url"
        case givenTitle     = "given_title"
        case resolvedTitle  = "resolved_title"
        case isFavorite     = "favorite"

    }

    /// A unique identifier matching the saved item. This id must be used to perform any actions through
    /// the [v3/modify](https://getpocket.com/developer/docs/v3/modify) endpoint.
    public let id: String
    /// A unique identifier similar to the item `id` but is unique to the actual url of the saved item.
    ///
    /// The `resolvedId` identifies unique urls. For example a direct link to a New York Times article and a link that redirects (ex a shortened bit.ly url)
    /// to the same article will share the same `resolvedId`. If this value is `0`, it means that Pocket has not processed the item. Normally this happens
    /// within seconds but is possible you may request the item before it has been resolved.
    public let resolvedId: String
    /// The actual url that was saved with the item. This url should be used if the user wants to view the item.
    public let givenUrl: String
    /// The final url of the item. For example if the item was a shortened bit.ly link, this will be the actual article the url linked to.
    public let resolvedUrl: String
    /// The title that was saved along with the item.
    public let givenTitle: String
    /// The title that Pocket found for the item when it was parsed
    public let resolvedTitle: String

}
