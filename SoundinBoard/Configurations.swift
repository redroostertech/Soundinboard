import Foundation
import UIKit
import AVFoundation
import CoreLocation
import GoogleMobileAds
import AudioToolbox
import Parse
import SystemConfiguration
import ChameleonFramework

// ------------------------------------------------
// MARK: - REPALCE THE STRING BELOW TO SET YOUR OWN APP NAME
// ------------------------------------------------
let APP_NAME = "SoundinBoard"

// ------------------------------------------------
// MARK: - REPLACE THE STRINGS BELOW WITH YOUR OWN 'App ID' AND 'Client Key' FROM YOUR PARSE APP ON https://back4app.com
// ------------------------------------------------
let PARSE_APP_ID = "9khyZ6CQOCovq1D9DolNzQHuXA9bzzAGVLtAK9Et"
let PARSE_CLIENT_KEY = "7Ny8U4dmerkXL4U4lrAdfObgB8Ibrx70uRuIf06y"

//let PARSE_APP_ID = "yOXXKpMohBQ5NyKbLpP4pDh8QXDAEnJpC0J2irOC"
//let PARSE_CLIENT_KEY = "rlJ3Ebk5YhTb1Hgd68BAGm7m5X3MxHLpWbjtlCrr"

// ------------------------------------------------
// MARK: - REPLACE THE RED STRING BELOW WITH YOUR OWN BANNER UNIT ID YOU'LL GET FROM  http://apps.admob.com
// ------------------------------------------------
let ADMOB_INTERSTITIAL_UNIT_ID = "ca-app-pub-6844181679066097/9613251746"

// ------------------------------------------------
// MARK: - EDIT THE RGBA VALUES BELOW AS YOU WISH
// ------------------------------------------------
let MAIN_COLOR = UIColor.hexValue(hex: "#8344af")

// ------------------------------------------------
// MARK: - EDIT THE EMAIL ADDRESS BELOW AS YOU WISH, IN ORDER TO ALLOW CLIENTS TO CONTACT YOU IN CASE OF SUPPORT
// ------------------------------------------------
let SUPPORT_EMAIL_ADDRESS = "soundinboardapp@gmail.com"

// ------------------------------------------------
// MARK: - ARRAY OF STUFF CATEGORIES - YOU CAN EDIT IT AS YOU WISH
// ------------------------------------------------
var categoriesArray = [
    
    // First fixed Categories (NOTE: these 3 items must alwasy be at the first index position)
    "latest",
    "trending",
    "answer",
    
    //---------------------
    // Categories:
    "photography",
    "health",
    "tech",
    "movies",
    "politics",
    "music",
    "psychology",
    "books",
    "sport",
    "science",
    "education",
    
    // YOU CAN ADD NEW CATEGORIES HERE, ALL LOWERCASED...
    
]

let colorsArray = [
    "#000000",   // latest
    "#444444",   // trending
    "#777777",  // answer
    
    //-------------------------------
    "#8344af",   // photography
    "#ed5564",   // health
    "#fc6d52",   // tech
    "#d870ad",   // movies
    "#8cc051",   // politics
    "#5d9bec",   // music
    "#48cfae",   // psycology
    "#39bf68",   // books
    "#8344af",   // sport
    "#ed5564",   // science
    "#fc6d52",   // education

    // YOU CAN ADD COLORS HERE...
    
]

// -------------------------------------------------------
// MARK: - PARSE DASHBOARD CLASSES AND COLUMNS NAMES
// -------------------------------------------------------
let USER_CLASS_NAME = "_User"
let USER_USERNAME = "username"
let USER_EMAIL = "email"
let USER_EMAIL_VERIFIED = "emailVerified"
let USER_FULLNAME = "fullName"
let USER_AVATAR = "avatar"
let USER_LOCATION = "location"
let USER_EDUCATION = "education"
let USER_REPORTED_BY = "reportedBy"

let QUESTIONS_CLASS_NAME = "Questions"
let QUESTIONS_QUESTION = "question"
let QUESTIONS_IMAGE = "image"
let QUESTIONS_CATEGORY = "category"
let QUESTIONS_ANSWERS = "answers"
let QUESTIONS_KEYWORDS = "keywords"
let QUESTIONS_USER_POINTER = "userPointer"
let QUESTIONS_VIEWS = "views"
let QUESTIONS_COLOR = "color"
let QUESTIONS_IS_ANONYMOUS = "isAnonymous"
let QUESTIONS_HAS_BEST_ANSWER = "hasBestAnswer"
let QUESTIONS_REPORTED_BY = "reportedBy"
let QUESTIONS_CREATED_AT = "createdAt"

let ANSWERS_CLASS_NAME = "Answers"
let ANSWERS_QUESTION_POINTER = "questionPointer"
let ANSWERS_USER_POINTER = "userPointer"
let ANSWERS_IS_ANONYMOUS = "isAnonymous"
let ANSWERS_ANSWER = "answer"
let ANSWERS_IMAGE = "image"
let ANSWERS_IS_BEST = "isBest"
let ANSWERS_LIKES = "likes"
let ANSWERS_LIKED_BY = "likedBy"
let ANSWERS_DISLIKES = "dislikes"
let ANSWERS_DISLIKED_BY = "dislikedBy"
let ANSWERS_REPORTED_BY = "reportedBy"
let ANSWERS_CREATED_AT = "createdAt"

let NOTIFICATIONS_CLASS_NAME = "Notifications"
let NOTIFICATIONS_CURRENT_USER = "currUser"
let NOTIFICATIONS_OTHER_USER = "otherUser"
let NOTIFICATIONS_TEXT = "text"
let NOTIFICATIONS_CREATED_AT = "createdAt"

// ------------------------------------------------
// MARK: - GLOBAL VARIABLES
// ------------------------------------------------
var mustDismiss = false
var noReload = false
var mustReload = false
var DEFAULTS = UserDefaults.standard
var allowPush = Bool()

// ------------------------------------------------
// MARK: - UTILITY EXTENSIONS
// ------------------------------------------------
var hud = UIView()
var loadingCircle = UIImageView()
var toast = UILabel()
