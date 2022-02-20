//
//  AddedItem.swift
//  Pocket
//
//  Created by Sören Gade on 19.02.22.
//


import Foundation


/// An item that was added to the Pocket queue.
///
/// The documentation and item setup is taken from the [Pocket developer documentation](https://getpocket.com/developer/docs/v3/add).
public struct AddedItem: Decodable {

    private enum CodingKeys: String, CodingKey {

        case id             = "item_id"
        case normalUrl      = "normal_url"
        case resolvedId     = "resolved_id"
        case resolvedUrl    = "resolved_url"
        case domainId       = "domain_id"
        case originDomainId = "origin_domain_id"
        case responseCode   = "response_code"
        case mimeType       = "mime_type"
        case contentLength  = "content_length"
        case encoding
        case dateResolved   = "date_resolved"
        case datePublished  = "date_published"
        case title
        case excerpt
        case wordCount      = "word_count"
        case hasImage       = "has_image"
        case hasVideo       = "has_video"
        case isIndex        = "is_index"
        case isArticle      = "is_article"
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

            case authorId   = "author_id"
            case name
            case url

        }

        public let authorId: StringInt
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

        public let id: StringInt
        public let source: String
        public let width: StringInt
        public let height: StringInt

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

        public let id: StringInt
        public let videoId: StringInt
        public let source: String
        public let width: StringInt
        public let height: StringInt
        public let type: String // TODO: Find out the meaning of this
        public let vid: String // this is probably the youtube-specific video id
        public let length: StringInt

    }

    /// A unique identifier matching the added item.
    public let id: StringInt

    /// The original url for the added item.
    public let normalUrl: String

    /// A unique identifier for the resolved item.
    public let resolvedId: StringInt

    /// The resolved url for the added item. The easiest way to think about the `resolvedUrl` - if you add a bit.ly
    /// link, the `resolvedUrl` will be the url of the page the bit.ly link points to.
    public let resolvedUrl: String

    /// A unique identifier for the domain of the `resolvedUrl`.
    public let domainId: StringInt

    /// A unique identifier for the domain of the `normalUrl`.
    public let originDomainId: StringInt

    /// The response code received by the Pocket parser when it tried to access the item.
    public let responseCode: StringInt

    /// The MIME type returned by the item.
    public let mimeType: String

    /// The content length of the item.
    public let contentLength: StringInt

    /// The encoding of the item.
    public let encoding: String

    /// The date the item was resolved.
    public let dateResolved: String

    /// The date the item was published (if the parser was able to find one).
    public let datePublished: String

    /// The title of the `resolvedUrl`.
    public let title: String

    /// The excerpt of the `resolvedUrl`.
    public let excerpt: String

    /// For an article, the number of words.
    public let wordCount: StringInt

    /// If the item has an image in the body of the article or if the item is an image.
    public let hasImage: AssetInformation

    /// If the item has a video in the body of the article or if the item is a video.
    public let hasVideo: AssetInformation

    /// True, if the parser thinks this item is an index page.
    public let isIndex: StringBool

    /// True, if the parser thinks this item is an article.
    public let isArticle: StringBool

    /// All of the authors associated with the item.
    public let authors: ObjectList<Author> // TODO: replace this with custom coding logic to replace it with a simple array

    /// All of the images associated with the item.
    public let images: ObjectList<Image> // TODO: replace this with custom coding logic to replace it with a simple array

    /// All of the videos associated with the item.
    public let videos: ObjectList<Video> // TODO: replace this with custom coding logic to replace it with a simple array

}
