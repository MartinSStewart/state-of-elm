module AdminPage exposing (AdminLoginData, FormMapData, Msg(..), ToBackend(..), adminView, update)

import AssocSet as Set exposing (Set)
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Effect.Time
import Element exposing (Element)
import Element.Font
import Element.Input
import Env
import Form exposing (Form, FormMapping)
import List.Extra as List
import Questions exposing (Question)
import Serialize
import Ui


type Msg
    = PressedLogOut
    | TypedFormsData String
    | TypedMapTo (FormMapping FormMapData)


type ToBackend
    = ReplaceFormsRequest (List Form)
    | LogOutRequest


type alias AdminLoginData =
    { forms : List { form : Form, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormMapping FormMapData
    }


type alias FormMapData =
    List { groupName : String, otherAnswers : Set String }


update : Msg -> AdminLoginData -> ( AdminLoginData, Command FrontendOnly ToBackend Msg )
update msg admin =
    case msg of
        TypedFormsData text ->
            if Env.isProduction then
                ( admin, Command.none )

            else
                case Serialize.decodeFromString (Serialize.list Form.formCodec) text of
                    Ok forms ->
                        ( { admin
                            | forms =
                                List.map
                                    (\form -> { form = form, submitTime = Just (Effect.Time.millisToPosix 0) })
                                    forms
                          }
                        , ReplaceFormsRequest forms |> Effect.Lamdera.sendToBackend
                        )

                    Err _ ->
                        ( admin, Command.none )

        PressedLogOut ->
            ( admin, Effect.Lamdera.sendToBackend LogOutRequest )

        TypedMapTo newFormMapping ->
            ( { admin | formMapping = newFormMapping }, Command.none )


adminView : AdminLoginData -> Element Msg
adminView admin =
    let
        formMapping =
            admin.formMapping
    in
    Element.column
        [ Element.spacing 32, Element.padding 16 ]
        [ Element.el [ Element.Font.size 36 ] (Element.text "Admin view")
        , Ui.button PressedLogOut "Log out"
        , Element.Input.text
            []
            { onChange = TypedFormsData
            , text =
                List.filterMap
                    (\{ form, submitTime } ->
                        case submitTime of
                            Just _ ->
                                Just form

                            Nothing ->
                                Nothing
                    )
                    admin.forms
                    |> Serialize.encodeToString (Serialize.list Form.formCodec)

            --|> Json.Encode.encode 0
            , placeholder = Nothing
            , label = Element.Input.labelHidden ""
            }
        , answerMappingView
            (\dict -> { formMapping | otherLanguages = dict })
            (List.filterMap
                (\{ form, submitTime } ->
                    case submitTime of
                        Just _ ->
                            if form.otherLanguages.otherChecked then
                                Just form.otherLanguages.otherText

                            else
                                Nothing

                        Nothing ->
                            Nothing
                )
                admin.forms
            )
            admin.formMapping.otherLanguages
        , Element.column
            [ Element.spacing 32 ]
            (List.map adminFormView admin.forms)
        ]


answerMappingView : (FormMapData -> FormMapping FormMapData) -> List String -> FormMapData -> Element Msg
answerMappingView updateFormMapping otherAnswers mapTo =
    Element.column
        [ Element.spacing 24 ]
        [ Element.row
            [ Element.spacing 8 ]
            (List.indexedMap
                (\index { groupName } ->
                    Element.row []
                        [ Element.el [ Element.Font.italic ] (Element.text ("(" ++ getHotkey index ++ ") "))
                        , Element.Input.text
                            [ Element.width (Element.px 100) ]
                            { text = groupName
                            , onChange =
                                \text ->
                                    List.updateAt
                                        index
                                        (\data -> { data | groupName = text })
                                        mapTo
                                        |> updateFormMapping
                                        |> TypedMapTo
                            , placeholder = Nothing
                            , label = Element.Input.labelHidden "mapTo"
                            }
                        ]
                )
                mapTo
                ++ [ Element.row []
                        [ Element.el [ Element.Font.italic ] (Element.text "(new) ")
                        , Element.Input.text
                            [ Element.width (Element.px 100) ]
                            { text = ""
                            , onChange =
                                \text ->
                                    mapTo
                                        ++ [ { groupName = text, otherAnswers = Set.empty } ]
                                        |> updateFormMapping
                                        |> TypedMapTo
                            , placeholder = Nothing
                            , label = Element.Input.labelHidden "mapTo"
                            }
                        ]
                   ]
            )
        , List.take 10 otherAnswers
            |> List.indexedMap
                (\index other ->
                    Element.el
                        [ if index == 0 then
                            Element.Font.bold

                          else
                            Element.Font.regular
                        ]
                        (Element.text other)
                )
            |> Element.column [ Element.spacing 8 ]
        ]


getHotkey : Int -> String
getHotkey index =
    String.fromChar (Char.fromCode (index + Char.toCode 'a'))


adminFormView : { form : Form, submitTime : Maybe Effect.Time.Posix } -> Element msg
adminFormView { form, submitTime } =
    Element.column
        [ Element.spacing 8 ]
        [ case submitTime of
            Just time ->
                Element.text ("Submitted at " ++ String.fromInt (Effect.Time.posixToMillis time))

            Nothing ->
                Element.text "Not submitted"
        , infoRow "doYouUseElm" (setToString Questions.doYouUseElm form.doYouUseElm)
        , infoRow "age" (maybeToString Questions.age form.age)
        , infoRow "functionalProgrammingExperience" (maybeToString Questions.experienceLevel form.functionalProgrammingExperience)
        , infoRow "otherLanguages" (multichoiceToString Questions.otherLanguages form.otherLanguages)
        , infoRow "newsAndDiscussions" (multichoiceToString Questions.newsAndDiscussions form.newsAndDiscussions)
        , infoRow "elmResources" (multichoiceToString Questions.elmResources form.elmResources)
        , infoRow "countryLivingIn" form.countryLivingIn
        , infoRow "applicationDomains" (multichoiceToString Questions.whereDoYouUseElm form.applicationDomains)
        , infoRow "doYouUseElmAtWork" (maybeToString Questions.doYouUseElmAtWork form.doYouUseElmAtWork)
        , infoRow "howLargeIsTheCompany" (maybeToString Questions.howLargeIsTheCompany form.howLargeIsTheCompany)
        , infoRow "whatLanguageDoYouUseForBackend" (multichoiceToString Questions.whatLanguageDoYouUseForTheBackend form.whatLanguageDoYouUseForBackend)
        , infoRow "howLong" (maybeToString Questions.howLong form.howLong)
        , infoRow "elmVersion" (multichoiceToString Questions.whatElmVersion form.elmVersion)
        , infoRow "doYouUseElmFormat" (maybeToString Questions.doYouUseElmFormat form.doYouUseElmFormat)
        , infoRow "stylingTools" (multichoiceToString Questions.stylingTools form.stylingTools)
        , infoRow "buildTools" (multichoiceToString Questions.buildTools form.buildTools)
        , infoRow "frameworks" (multichoiceToString Questions.frameworks form.frameworks)
        , infoRow "editors" (multichoiceToString Questions.editor form.editors)
        , infoRow "doYouUseElmReview" (maybeToString Questions.doYouUseElmReview form.doYouUseElmReview)
        , infoRow "whichElmReviewRulesDoYouUse" (multichoiceToString Questions.whichElmReviewRulesDoYouUse form.whichElmReviewRulesDoYouUse)
        , infoRow "testTools" (multichoiceToString Questions.testTools form.testTools)
        , infoRow "testsWrittenFor" (multichoiceToString Questions.testsWrittenFor form.testsWrittenFor)
        , infoRow "elmInitialInterest" form.elmInitialInterest
        , infoRow "biggestPainPoint" form.biggestPainPoint
        , infoRow "whatDoYouLikeMost" form.whatDoYouLikeMost
        , infoRow "emailAddress" form.emailAddress
        ]


multichoiceToString : Question a -> Ui.MultiChoiceWithOther a -> String
multichoiceToString { choiceToString } multiChoiceWithOther =
    Set.toList multiChoiceWithOther.choices
        |> List.map choiceToString
        |> (\choices ->
                if multiChoiceWithOther.otherChecked then
                    choices ++ [ multiChoiceWithOther.otherText ]

                else
                    choices
           )
        |> String.join ", "


setToString : Question a -> Set a -> String
setToString { choiceToString } set =
    Set.toList set
        |> List.map choiceToString
        |> String.join ", "


maybeToString : Question a -> Maybe a -> String
maybeToString { choiceToString } maybe =
    case maybe of
        Just a ->
            choiceToString a

        Nothing ->
            ""


infoRow name value =
    Element.row
        [ Element.spacing 24 ]
        [ Element.el [ Element.Font.color (Element.rgb 0.4 0.5 0.5) ] (Element.text name)
        , Element.paragraph [] [ Element.text value ]
        ]
