public typealias Parameters = [VK.Arg: String?]

extension Dictionary where Key == VK.Arg, Value == String? {
    static var empty: [VK.Arg: String?] {
        return [:]
    }
}

// swiftlint:disable type_body_length identifier_name
extension VK {
  ///Parameters for methods VK API
  public enum Arg: String, Hashable {
    case userIDs = "user_ids"
    case fields
    case nameCase = "name_case"
    case q
    case sort
    case offset
    case count
    case city
    case country
    case hometown
    case universityCountry = "university_country"
    case university
    case universityYear = "university_year"
    case universityFaculty = "university_faculty"
    case universityChair = "university_chair"
    case sex
    case status
    case ageFrom = "age_from"
    case ageTo = "age_to"
    case birthDay = "birth_day"
    case birthMonth = "birth_month"
    case birthYear = "birth_year"
    case online
    case hasPhoto = "has_photo"
    case schoolCountry = "school_country"
    case schoolCity = "school_city"
    case schoolClass = "school_class"
    case school
    case schoolYear = "school_year"
    case religion
    case interests
    case company
    case position
    case groupId = "group_id"
    case userId = "user_id"
    case extended
    case comment
    case latitude
    case longitude
    case accuracy
    case timeout
    case radius
    case groupIds = "group_ids"
    case notSure = "not_sure"
    case countryId = "country_id"
    case future
    case endDate = "end_date"
    case reason
    case commentVisible = "comment_visible"
    case title
    case description
    case type
    case order
    case listId = "list_id"
    case onlineMobile = "online_mobile"
    case sourceUid = "source_uid"
    case targetUid = "target_uid"
    case targetUids = "target_uids"
    case needMutual = "need_mutual"
    case out
    case suggested
    case text
    case listIds = "list_ids"
    case name
    case addUserIds = "add_user_ids"
    case deleteUserIds = "delete_user_ids"
    case phones
    case needSign = "need_sign"
    case ownerId = "owner_id"
    case domain
    case query
    case ownersOnly = "owners_only"
    case posts
    case copyHistoryDepth = "copy_history_depth"
    case friendsOnly = "friends_only"
    case fromGroup = "from_group"
    case message
    case attachments
    case attachment
    case services
    case signed
    case publishDate = "publish_date"
    case lat
    case long
    case placeId = "place_id"
    case postId = "post_id"
    case object
    case needLikes = "need_likes"
    case previewLength = "preview_length"
    case replyToComment = "reply_to_comment"
    case stickerId = "sticker_id"
    case commentId = "comment_id"
    case commentPrivacy = "comment_privacy"
    case privacy
    case albumIds = "album_ids"
    case needSystem = "need_system"
    case needCovers = "need_covers"
    case photoSizes = "photo_sizes"
    case rev
    case feedType = "feed_type"
    case feed
    case photos
    case chatId = "chat_id"
    case cropX = "crop_x"
    case cropY = "crop_y"
    case cropWidth = "crop_width"
    case server
    case hash
    case photo
    case photoId = "photo_id"
    case startTime = "start_time"
    case endTime = "end_time"
    case photosList = "photos_list"
    case caption
    case accessKey = "access_key"
    case access
    case targetAlbumId = "target_album_id"
    case albumId = "album_id"
    case before
    case after
    case noServiceAlbums = "no_service_albums"
    case tagId = "tag_id"
    case x
    case y
    case x2
    case y2
    case videos
    case width
    case videoId = "video_id"
    case desc
    case privacyView = "privacy_view"
    case privacyComment = "privacy_comment"
    case `repeat`
    case isPrivate = "is_private"
    case wallpost
    case link
    case hd
    case adult
    case searchOwn = "search_own"
    case longer
    case shorter
    case videoIds = "video_ids"
    case taggedName = "tagged_name"
    case searchQuery = "search_query"
    case audioIds = "audio_ids"
    case needUser = "need_user"
    case audios
    case lyricsId = "lyrics_id"
    case autoComplete = "auto_complete"
    case lyrics
    case performerOnly = "performer_only"
    case audio
    case audioId = "audio_id"
    case artist
    case genreId = "genre_id"
    case noSearch = "no_search"
    case targetIds = "target_ids"
    case active
    case targetAudio = "target_audio"
    case shuffle
    case onlyEng = "only_eng"
    case timeOffset = "time_offset"
    case lastMessageId = "last_message_id"
    case unread
    case messageIds = "message_ids"
    case startMessageId = "start_message_id"
    case guid
    case forwardMessages = "forward_messages"
    case peerId = "peer_id"
    case important
    case useSsl = "use_ssl"
    case needPts = "need_pts"
    case ts
    case pts
    case onlines
    case eventsLimit = "events_limit"
    case msgsLimit = "msgs_limit"
    case maxMsgId = "max_msg_id"
    case chatIds = "chat_ids"
    case limit
    case file
    case returnBanned = "return_banned"
    case maxPhotos = "max_photos"
    case sourceIds = "source_ids"
    case startFrom = "start_from"
    case nextFrom = "next_from"
    case reposts
    case lastCommentsCount = "last_comments_count"
    case itemId = "item_id"
    case noReposts = "no_reposts"
    case pageUrl = "page_url"
    case key
    case keys
    case global
    case value
    case voip
    case contacts
    case myContact
    case returnAll = "return_all"
    case token
    case deviceModel = "device_model"
    case systemVersion = "system_version"
    case noText = "no_text"
    case subscribe
    case sound
    case intro
    case restoreSid = "restore_sid"
    case changePasswordHash = "change_password_hash"
    case oldPassword = "old_password"
    case newPassword = "new_password"
    case firstName = "first_name"
    case lastName = "last_name"
    case maidenName = "maiden_name"
    case cancelRequestId = "cancel_request_id"
    case relation
    case relationPartnerId = "relation_partner_id"
    case bdate
    case bdateVisibility = "bdate_visibility"
    case homeTown = "home_town"
    case cityId = "city_id"
    case phone
    case clientId = "client_id"
    case clientSecret = "client_secret"
    case code
    case password
    case testMode = "test_mode"
    case voice
    case sid
    case sitePreview = "site_preview"
    case needSource = "need_source"
    case needHtml = "need_html"
    case pageId = "page_id"
    case view
    case edit
    case versionId = "version_id"
    case topicIds = "topic_ids"
    case preview
    case topicId = "topic_id"
    case noteIds = "note_ids"
    case noteId = "note_id"
    case needWiki = "need_wiki"
    case replyTo = "reply_to"
    case address
    case places
    case timestamp
    case needPlaces = "need_places"
    case isBoard = "is_board"
    case pollId = "poll_id"
    case answerId = "answer_id"
    case answerIds = "answer_ids"
    case question
    case isAnonymous = "is_anonymous"
    case addAnswers = "add_answers"
    case editAnswers = "edit_answers"
    case deleteAnswers = "delete_answers"
    case docs
    case tags
    case docId = "doc_id"
    case from
    case appId = "app_id"
    case dateFrom = "date_from"
    case dateTo = "date_to"
    case searchGlobal = "search_global"
    case platform
    case returnFriends = "return_friends"
    case url
    case needAll = "need_all"
    case streetIds = "street_ids"
    case countryIds = "country_ids"
    case regionId = "region_id"
    case cityIds = "city_ids"
    case universityId = "university_id"
    case facultyId = "faculty_id"
    case captcha = "captcha.force"
    case captchaSid = "captcha_sid"
    case captchaKey = "captcha_key"
    case screenName = "screen_name"
    case appIDs = "app_ids"
    case mainPhoto = "main_photo"
    case cropData = "crop_data"
    case cropHash = "crop_hash"
    case website
    case subject
    case email
    case rss
    case eventStartDate = "event_start_date"
    case eventFinishDate = "event_finish_date"
    case eventGroupId = "event_group_id"
    case publicCategory = "public_category"
    case publicSubcategory = "public_subcategory"
    case publicDate = "public_date"
    case wall
    case topics
    case video
    case links
    case events
    case wiki
    case messages
    case ageLimits = "age_limits"
    case market
    case marketComments = "market_comments"
    case marketCountry = "market_country"
    case marketCity = "market_city"
    case marketCurrency = "market_currency"
    case marketContact = "market_contact"
    case marketWiki = "market_wiki"
    case obsceneFilter = "obscene_filter"
    case obsceneStopwords = "obscene_stopwords"
    case obsceneWords = "obscene_words"
    case subcategories
    case randomId = "random_id"
    case aid
    case gid
    case deviceId = "device_id"
    case sandbox

    public var hashValue: Int {
      return self.rawValue.hashValue
    }
  }
}

public func == (lhs: VK.Arg, rhs: VK.Arg) -> Bool {
  return lhs.rawValue == rhs.rawValue
}
