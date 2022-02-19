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
public struct Item: Decodable {

    private enum CodingKeys: String, CodingKey {

        case id             = "item_id"
        case resolvedId     = "resolved_id"
        case givenUrl       = "given_url"
        case resolvedUrl    = "resolved_url"
        case givenTitle     = "given_title"
        case resolvedTitle  = "resolved_title"
        case isFavorite     = "favorite"
        case status
        case excerpt
        case isArticle      = "is_article"
        case hasImage       = "has_image"
        case hasVideo       = "has_video"
        case wordCount      = "word_count"
        case authors
        case images
        case videos

    }

    public enum Status: String, Decodable {

        case none               = "0"
        case archived           = "1"
        case shouldBeDeleted    = "2"

    }

    public enum AssetInformation: String, Decodable {

        case none           = "0"
        case containsAssets = "1"
        case isAsset        = "2"

    }

    public struct Author: Decodable {

        private enum CodingKeys: String, CodingKey {

            case id         = "item_id"
            case authorId   = "author_id"
            case name
            case url

        }

        public let id: Int
        public let authorId: Int
        public let name: String
        public let url: String

    }

    public struct Image: Decodable {

        private enum CodingKeys: String, CodingKey {

            case id     = "item_id"
            case source = "src"
            case width
            case height

        }

        public let id: Int
        public let source: String
        public let width: Int
        public let height: Int

    }

    public struct Video: Decodable {

        private enum CodingKeys: String, CodingKey {

            case id         = "item_id"
            case videoId    = "video_id"
            case source     = "src"
            case width
            case height
            case type
            case vid
            case length

        }

        public let id: Int
        public let videoId: Int
        public let source: String
        public let width: Int
        public let height: Int
        public let type: String // TODO: Find out the meaning of this
        public let vid: String // this is probably the youtube-specific video id
        public let length: Int

    }

    /// A unique identifier matching the saved item. This id must be used to perform any actions through
    /// the [v3/modify](https://getpocket.com/developer/docs/v3/modify) endpoint.
    public let id: Int

    /// A unique identifier similar to the item `id` but is unique to the actual url of the saved item.
    ///
    /// The `resolvedId` identifies unique urls. For example a direct link to a New York Times article and a link
    /// that redirects (ex a shortened bit.ly url) to the same article will share the same `resolvedId`. If this value
    /// is `0`, it means that Pocket has not processed the item. Normally this happens within seconds but is possible
    /// you may request the item before it has been resolved.
    public let resolvedId: Int

    /// The actual url that was saved with the item. This url should be used if the user wants to view the item.
    public let givenUrl: String

    /// The final url of the item. For example if the item was a shortened bit.ly link, this will be the actual article
    /// the url linked to.
    public let resolvedUrl: String

    /// The title that was saved along with the item.
    public let givenTitle: String

    /// The title that Pocket found for the item when it was parsed.
    public let resolvedTitle: String

    /// If the item is favorited.
    public let isFavorite: StringBool

    /// If the item is archived or if the item should be deleted.
    public let status: Status

    /// The first few lines of the item (articles only).
    public let excerpt: String?

    /// If the item is an article.
    public let isArticle: StringBool

    /// If the item has images in it or if the item is an image.
    public let hasImage: AssetInformation

    /// If the item has videos in it ir if the item is a video.
    public let hasVideo: AssetInformation

    /// How many words are in the article.
    public let wordCount: Int

    /// All of the authors associated with the item.
    public let authors: NumberedArray<Author> // TODO: replace this with custom coding logic to replace it with a simple array

    /// All of the images associated with the item.
    public let images: NumberedArray<Image> // TODO: replace this with custom coding logic to replace it with a simple array

    /// All of the videos associated with the item.
    public let videos: NumberedArray<Video> // TODO: replace this with custom coding logic to replace it with a simple array

}
