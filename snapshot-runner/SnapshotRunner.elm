port module SnapshotRunner exposing (main)

import ABTest exposing (ABTest(..))
import Area
import AssocList as Dict exposing (Dict)
import AssocSet as Set
import Bytes exposing (Bytes)
import Date
import Duration
import Effect.Snapshot exposing (PercyApiKey(..), Snapshot)
import Effect.Test
import Effect.Time as Time
import EmailViewer
import EndToEndTests
import Frontend
import HomePage
import Html
import Id exposing (Id, RealtorId)
import Image
import Json.Decode exposing (Decoder)
import List.Nonempty exposing (Nonempty(..))
import LivingArea exposing (LivingArea(..))
import MapExtraLayers exposing (TextureStatus(..))
import MapPage
import MinSales exposing (MinSales(..))
import Pixels
import Point2d
import PropertyType
import Quantity
import Realtor exposing (Realtor)
import RealtorResponse
import RoomCount exposing (RoomCount(..))
import Route exposing (Route)
import Sale exposing (Sale)
import SaleInfoOverlay exposing (Model(..))
import SearchRegion
import SearchType exposing (SearchType(..))
import Size exposing (Size)
import SortRealtorBy exposing (SortRealtorBy(..))
import Task
import Types exposing (FrontendModel(..), LoadedFrontend, Page(..))
import Ui
import Units
import Unsafe


type alias Flags =
    { currentBranch : String
    , filepaths : List String
    , percyApiKey : String
    }


type alias Model =
    Result () OkModel


type alias OkModel =
    { files : Dict String Bytes
    , currentBranch : String
    , remainingFilepaths : Nonempty String
    , percyApiKey : PercyApiKey
    }


type Msg
    = FileResponse Bytes
    | UploadFinished (Result Effect.Snapshot.Error { success : Bool })


port requestFile : String -> Cmd msg


port fileResponse : (Bytes -> msg) -> Sub msg


port writeLine : String -> Cmd msg


snapshots : Nonempty (Snapshot ())
snapshots =
    Nonempty
        { name = "Confirmation email"
        , body = [ EmailViewer.confirmationEmail ]
        , widths = Nonempty 350 [ 800, 1920 ]
        , minimumHeight = Nothing
        }
        ({ name = "Realtor email"
         , body = [ EmailViewer.realtorEmail ]
         , widths = Nonempty 350 [ 800, 1920 ]
         , minimumHeight = Nothing
         }
            :: List.concat
                [ pages "Home page with side menu"
                    (\_ ->
                        { navigationKey = Effect.Test.fakeNavigationKey
                        , route = Route.homepageRoute
                        , time = Time.millisToPosix 10000000
                        , timezone = Time.utc
                        , lastConnectionCheck = Time.millisToPosix 10000000
                        , windowSize = { width = Quantity.zero, height = Quantity.zero }
                        , currentPage = HomePage_ HomePage.init
                        , showSideMenu = True
                        , msgHistory = []
                        , trackingEnabled = False
                        , metadata = { referrer = "", userAgent = "", platform = "win32" }
                        , font = Nothing
                        , mapConfig =
                            { realtorTexture = TextureNotLoaded
                            , textures = Dict.empty
                            , devicePixelRatio = 1
                            }
                        , abTest = TestA
                        }
                    )
                , pages "Terms of service" (\_ -> initModel Route.TermsOfServiceRoute TermsOfServicePage)
                , pages "Privacy policy" (\_ -> initModel Route.PrivacyPolicyRoute PrivacyPolicyPage)
                , pages "About us" (\_ -> initModel Route.AboutUsRoute AboutUsPage)
                , pages "FAQ" (\_ -> initModel Route.FaqRoute FaqPage)
                , pages "Realtors offering page" (\_ -> initModel Route.RealtorsOfferingRoute RealtorsOfferingPage)
                , pages "Map sale info popup"
                    (\windowSize ->
                        initModel (Route.MapRoute mapRoute)
                            (mapPage windowSize
                                |> (\a ->
                                        { a
                                            | realtorData =
                                                RealtorResponse.loadRealtorData
                                                    { cityAndDistrict =
                                                        { city = Nothing, district = Nothing, municipality = Nothing }
                                                    , location = Just { lng = 0, lat = 0 }
                                                    , realtors = [ ( realtorId0, realtor0 ), ( realtorId1, realtor1 ) ]
                                                    , averages =
                                                        { pricePerMeterSquared = Quantity.zero
                                                        , percentageIncrease = Nothing
                                                        , finalPrice = Quantity.zero
                                                        , bidders = Just Quantity.zero
                                                        , saleDuration = Nothing
                                                        , sales = Quantity.zero
                                                        }
                                                    , companies =
                                                        Dict.fromList
                                                            [ ( Id.fromString "husInc", { name = "Hus inc.", image = Nothing } )
                                                            , ( Id.fromString "Corporation Unlimited"
                                                              , { name = "Hus inc.", image = Nothing }
                                                              )
                                                            ]
                                                    }
                                                    RealtorResponse.RealtorDataFirstLoad
                                                    |> RealtorResponse.RealtorDataLoaded
                                            , selected = Set.fromList [ realtorId0 ]
                                            , saleInfoPopup =
                                                { mousePosition = Point2d.fromPixels { x = 10, y = 10 }
                                                , marker =
                                                    { realtorId = realtorId0
                                                    , saleId = List.Nonempty.head realtor0.sales |> .id
                                                    }
                                                }
                                                    |> SaleInfoOpened
                                        }
                                   )
                                |> MapPage_
                            )
                    )
                , List.map
                    (\windowSize ->
                        ( windowSize
                        , EndToEndTests.testList windowSize |> List.map EndToEndTests.getTest
                        )
                    )
                    [ { width = 350, height = 568 }
                    , { width = 900, height = 1024 }
                    , { width = 1920, height = 1080 }
                    ]
                    |> List.concatMap
                        (\( windowSize, tests ) ->
                            List.concatMap Effect.Test.toSnapshots tests
                                |> List.map
                                    (\snapshot ->
                                        { name =
                                            snapshot.name
                                                ++ " w: "
                                                ++ String.fromInt windowSize.width
                                                ++ ", h: "
                                                ++ String.fromInt windowSize.height
                                        , body = List.map (Html.map (\_ -> ())) snapshot.body
                                        , widths = snapshot.widths
                                        , minimumHeight = snapshot.minimumHeight
                                        }
                                    )
                        )
                ]
        )


mapPage : Size -> MapPage.Model
mapPage windowSize =
    MapPage.init 1 windowSize mapRoute |> Tuple.first


mapRoute : Route.MapRouteData
mapRoute =
    { propertyType = Route.AllPropertyTypes
    , sortBy = SortByMaxFinalPrice
    , roomCount = RoomCount Nothing Nothing
    , livingArea = LivingArea Nothing Nothing
    , excludedCompanies = Set.empty
    , minSales = MinSales3
    , searchType =
        SearchByAddress
            { placeId = Id.fromString "123"
            , streetAddressName = Unsafe.streetAddress "Kungsgatan 1, 111 56 Stockholm"
            , originalPlaceId = Id.fromString "123"
            , originalAddress = Unsafe.streetAddress "Kungsgatan 1, 111 56 Stockholm"
            , searchRegion = SearchRegion.Km15
            }
    , constructionYear = Set.empty
    }


realtorId0 : Id RealtorId
realtorId0 =
    Id.fromString "realtor0Id"


realtor0 : Realtor
realtor0 =
    { name = Unsafe.fullName "Gustav Johansson"
    , companyId = Id.fromString "husInc"
    , experience = Just (Units.years 5)
    , avgPerMeterSquared = Quantity.rate (Units.sek 10000) Area.squareMeter
    , maxPerMeterSquared = Quantity.rate (Units.sek 123123) Area.squareMeter
    , avgPercentageIncrease = Just 10
    , realEstatesSold = Units.realEstates 50
    , avgBiddersPerSale = Units.avgBiddersPerSale 20 |> Just
    , sales = Nonempty sale0 [ sale1 ]
    , avgSaleDuration = Duration.weeks 1.5 |> Just
    , avgFinalPrice = Units.sek 100000
    , maxFinalPrice = Units.sek 20000
    , hasImage = False
    , firstName = "Gustav"
    , initials = "GJ"
    }


realtorId1 : Id RealtorId
realtorId1 =
    Id.fromString "realtor1Id"


realtor1 : Realtor
realtor1 =
    { name = Unsafe.fullName "Emile Loven"
    , companyId = Id.fromString "corporationUnlimited"
    , experience = Nothing
    , avgPerMeterSquared = Quantity.rate (Units.sek 99999) Area.squareMeter
    , maxPerMeterSquared = Quantity.rate (Units.sek 100123) Area.squareMeter
    , avgPercentageIncrease = Nothing
    , realEstatesSold = Units.realEstates 50
    , avgBiddersPerSale = Nothing
    , sales = Nonempty sale0 [ sale1 ]
    , avgSaleDuration = Nothing
    , avgFinalPrice = Units.sek 120000
    , maxFinalPrice = Units.sek 10000
    , hasImage = False
    , firstName = "Emile"
    , initials = "EL"
    }


sale0 : Sale
sale0 =
    { id = Id.fromString "qwe"
    , soldAt = Time.millisToPosix 10000000
    , address = "Lunkmakargatan 15"
    , location = Just "Stockholm"
    , propertyType = Just PropertyType.Apartment
    , bidders = Just 15
    , position = { lng = 0, lat = 45 }
    , openingPrice = Units.sek 123123 |> Just
    , closingPrice = Units.sek 211313
    , area = Area.squareMeters 100 |> Just
    , rooms = Just (Units.halfRooms 3)
    , monthlyFee = Just (Units.sek 999)
    , floor = Just (Units.floors 5)
    , floorCount = Just (Units.floors 6)
    , dateOnMarket = Date.fromRataDie 100000 |> Just
    }


sale1 : Sale
sale1 =
    { id = Id.fromString "qwe1"
    , soldAt = Time.millisToPosix 10000000
    , address = "Lunkmakargatan 15"
    , location = Nothing
    , propertyType = Nothing
    , bidders = Nothing
    , position = { lng = 0, lat = 44 }
    , openingPrice = Nothing
    , closingPrice = Units.sek 1013130
    , area = Nothing
    , rooms = Nothing
    , monthlyFee = Nothing
    , floor = Just (Units.floors 5)
    , floorCount = Nothing
    , dateOnMarket = Nothing
    }


largeMobile : Size
largeMobile =
    { width = Ui.minDesktopWidth |> Quantity.minus Pixels.pixel, height = Pixels.pixels 1000 }


smallMobile : Size
smallMobile =
    { width = Pixels.pixels 350, height = Pixels.pixels 568 }


smallDesktop : Size
smallDesktop =
    { width = Ui.minDesktopWidth, height = Pixels.pixels 600 }


largeDesktop : Size
largeDesktop =
    { width = Pixels.pixels 1920, height = Pixels.pixels 1080 }


pages : String -> (Size -> LoadedFrontend) -> List (Snapshot ())
pages name model =
    [ page (name ++ " on small mobile") smallMobile (model smallMobile)
    , page (name ++ " on large mobile") largeMobile (model largeMobile)
    , page (name ++ " on small desktop") smallDesktop (model smallDesktop)
    , page (name ++ " on large desktop") largeDesktop (model largeDesktop)
    ]


page :
    String
    -> Size
    -> LoadedFrontend
    -> Snapshot ()
page name windowSize model =
    { name = name
    , body =
        { model | windowSize = windowSize }
            |> Loaded
            |> Frontend.view True
            |> .body
            |> List.map (Html.map (\_ -> ()))
    , widths = Nonempty (Pixels.inPixels windowSize.width) []
    , minimumHeight = Just (Pixels.inPixels windowSize.height)
    }


initModel : Route -> Page -> LoadedFrontend
initModel route page_ =
    { navigationKey = Effect.Test.fakeNavigationKey
    , route = route
    , time = Time.millisToPosix 10000000
    , timezone = Time.utc
    , lastConnectionCheck = Time.millisToPosix 10000000
    , windowSize = { width = Quantity.zero, height = Quantity.zero }
    , currentPage = page_
    , showSideMenu = False
    , msgHistory = []
    , trackingEnabled = False
    , metadata = { referrer = "", userAgent = "", platform = "win32" }
    , font = Nothing
    , mapConfig =
        { realtorTexture = TextureNotLoaded
        , textures = Dict.empty
        , devicePixelRatio = 1
        }
    , abTest = TestA
    }


decodeFlags : Decoder Flags
decodeFlags =
    Json.Decode.map3 Flags
        (Json.Decode.field "currentBranch" Json.Decode.string)
        (Json.Decode.field "filepaths" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "percyApiKey" Json.Decode.string)


main : Program Json.Decode.Value Model Msg
main =
    Platform.worker
        { init =
            \flagsJson ->
                case Json.Decode.decodeValue decodeFlags flagsJson of
                    Ok flags ->
                        case
                            flags.filepaths
                                ++ List.map Image.imageToRelativePath (List.Nonempty.toList Image.allImages)
                                |> List.Nonempty.fromList
                        of
                            Just nonempty ->
                                ( { files = Dict.empty
                                  , currentBranch = flags.currentBranch
                                  , remainingFilepaths = nonempty
                                  , percyApiKey = PercyApiKey flags.percyApiKey
                                  }
                                    |> Ok
                                , requestFile (List.Nonempty.head nonempty)
                                )

                            Nothing ->
                                let
                                    model =
                                        { files = Dict.empty
                                        , currentBranch = flags.currentBranch
                                        , remainingFilepaths = Nonempty "" []
                                        , percyApiKey = PercyApiKey flags.percyApiKey
                                        }
                                in
                                ( Ok model, upload model )

                    Err error ->
                        ( Err (), Json.Decode.errorToString error |> writeLine )
        , update = update
        , subscriptions = \_ -> fileResponse FileResponse
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileResponse content ->
            case model of
                Ok okModel ->
                    let
                        newModel =
                            { okModel
                                | files = Dict.insert (List.Nonempty.head okModel.remainingFilepaths) content okModel.files
                            }
                    in
                    case List.Nonempty.tail okModel.remainingFilepaths |> List.Nonempty.fromList of
                        Just nonempty ->
                            ( Ok { newModel | remainingFilepaths = nonempty }
                            , requestFile (List.Nonempty.head nonempty)
                            )

                        Nothing ->
                            ( Ok newModel, upload newModel )

                Err _ ->
                    ( model, Cmd.none )

        UploadFinished result ->
            case result of
                Ok { success } ->
                    ( model
                    , if success then
                        writeLine "Snapshots uploaded!"

                      else
                        writeLine "Failed to complete upload."
                    )

                Err error ->
                    ( model, writeLine (Effect.Snapshot.errorToString error) )


upload : OkModel -> Cmd Msg
upload model =
    Effect.Snapshot.uploadSnapshots
        { apiKey = model.percyApiKey
        , gitBranch = model.currentBranch
        , gitTargetBranch = "master"
        , snapshots = snapshots
        , publicFiles =
            Dict.toList model.files
                |> List.map (\( key, value ) -> { filepath = key, content = value })
        }
        |> Task.attempt UploadFinished
