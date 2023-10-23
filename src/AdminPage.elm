module AdminPage exposing
    ( AdminLoginData
    , AiCategorizationStatus(..)
    , FormMappingEdit(..)
    , Model
    , Msg(..)
    , SendEmailsStatus(..)
    , ToBackend(..)
    , ToFrontend(..)
    , adminView
    , groupPackagesBy
    , init
    , networkUpdate
    , update
    , updateFromBackend
    )

import AnswerMap exposing (AnswerMap, Hotkey, OtherAnswer)
import AssocList
import DataEntry
import Dict exposing (Dict)
import Effect.Browser.Dom as Dom exposing (HtmlId)
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera as Lamdera
import Effect.Time
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import EmailAddress exposing (EmailAddress)
import Env
import Form2023 exposing (Form2023, FormMapping, SpecificQuestion(..))
import FreeTextAnswerMap exposing (FreeTextAnswerMap)
import List.Extra as List
import NetworkModel exposing (NetworkModel)
import PackageName exposing (PackageName)
import Questions2023 as Questions exposing (Question)
import SendGrid
import Serialize
import Set exposing (Set)
import SurveyResults2023
import Ui exposing (MultiChoiceWithOther)


type Msg
    = PressedLogOut
    | TypedFormsData String
    | FormMappingEditMsg FormMappingEdit
    | PressedQuestionWithOther SpecificQuestion
    | PressedToggleShowEncodedState
    | NoOp
    | PressedSendEmails
    | PressedAiCategorization SpecificQuestion
    | SurveyMsg SurveyResults2023.Msg


type ToBackend
    = ReplaceFormsRequest ( List Form2023, FormMapping )
    | EditFormMappingRequest FormMappingEdit
    | LogOutRequest
    | SendEmailsRequest
    | AiCategorizationRequest SpecificQuestion


type ToFrontend
    = EditFormMappingResponse FormMappingEdit
    | SendEmailsResponse (List { emailAddress : EmailAddress, result : Result SendGrid.Error () })


type alias AdminLoginData =
    { forms : List { form : Form2023, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormMapping
    , sendEmailsStatus : SendEmailsStatus
    , aiCategorization : AssocList.Dict SpecificQuestion AiCategorizationStatus
    }


type FormMappingEdit
    = TypedGroupName SpecificQuestion Hotkey String
    | TypedNewGroupName SpecificQuestion String
    | TypedOtherAnswerGroups SpecificQuestion OtherAnswer String
    | RemoveGroup SpecificQuestion Hotkey
    | TypedComment SpecificQuestion String


type alias Model =
    { forms : List { form : Form2023, submitTime : Maybe Effect.Time.Posix }
    , formMapping : NetworkModel FormMappingEdit FormMapping
    , selectedMapping : SpecificQuestion
    , showEncodedState : Bool
    , sendEmailsStatus : SendEmailsStatus
    , aiCategorization : AssocList.Dict SpecificQuestion AiCategorizationStatus
    , resultMode : SurveyResults2023.Mode
    , resultSegment : SurveyResults2023.Segment
    , resultPackageMode : SurveyResults2023.PackageMode
    }


type SendEmailsStatus
    = EmailsNotSent
    | Sending
    | SendResult (List { emailAddress : EmailAddress, result : Result SendGrid.Error () })


init : AdminLoginData -> Model
init loginData =
    { forms = loginData.forms
    , formMapping = NetworkModel.init loginData.formMapping
    , selectedMapping = OtherLanguagesQuestion
    , showEncodedState = False
    , sendEmailsStatus = loginData.sendEmailsStatus
    , aiCategorization = loginData.aiCategorization
    , resultMode = SurveyResults2023.Percentage
    , resultSegment = SurveyResults2023.AllUsers
    , resultPackageMode = SurveyResults2023.GroupByPackageName
    }


allQuestions : List SpecificQuestion
allQuestions =
    [ DoYouUseElmQuestion
    , AgeQuestion
    , PleaseSelectYourGenderQuestion
    , FunctionalProgrammingExperienceQuestion
    , OtherLanguagesQuestion
    , NewsAndDiscussionsQuestion
    , ElmResourcesQuestion
    , CountryLivingInQuestion
    , ApplicationDomainsQuestion
    , DoYouUseElmAtWorkQuestion
    , HowLargeIsTheCompanyQuestion
    , WhatLanguageDoYouUseForBackendQuestion
    , HowLongQuestion
    , ElmVersionQuestion
    , DoYouUseElmFormatQuestion
    , StylingToolsQuestion
    , BuildToolsQuestion
    , FrameworksQuestion
    , EditorsQuestion
    , DoYouUseElmReviewQuestion
    , TestToolsQuestion
    , ElmInitialInterestQuestion
    , BiggestPainPointQuestion
    , WhatDoYouLikeMostQuestion
    , HowDidItGoUsingElmAtWork
    , WhatPreventsYouFromUsingElmAtWork
    , SurveyImprovementsQuestion
    , WhatPackagesDoYouUseQuestion
    ]


networkUpdate : FormMappingEdit -> FormMapping -> FormMapping
networkUpdate edit answerMap =
    case edit of
        RemoveGroup question hotkey ->
            let
                removeGroup : AnswerMap a -> AnswerMap a
                removeGroup =
                    AnswerMap.removeGroup hotkey

                removeGroup_ : FreeTextAnswerMap -> FreeTextAnswerMap
                removeGroup_ =
                    FreeTextAnswerMap.removeGroup hotkey
            in
            case question of
                OtherLanguagesQuestion ->
                    { answerMap | otherLanguages = removeGroup answerMap.otherLanguages }

                NewsAndDiscussionsQuestion ->
                    { answerMap | newsAndDiscussions = removeGroup answerMap.newsAndDiscussions }

                ElmResourcesQuestion ->
                    { answerMap | elmResources = removeGroup answerMap.elmResources }

                ApplicationDomainsQuestion ->
                    { answerMap | applicationDomains = removeGroup answerMap.applicationDomains }

                WhatLanguageDoYouUseForBackendQuestion ->
                    { answerMap | whatLanguageDoYouUseForBackend = removeGroup answerMap.whatLanguageDoYouUseForBackend }

                ElmVersionQuestion ->
                    { answerMap | elmVersion = removeGroup answerMap.elmVersion }

                StylingToolsQuestion ->
                    { answerMap | stylingTools = removeGroup answerMap.stylingTools }

                BuildToolsQuestion ->
                    { answerMap | buildTools = removeGroup answerMap.buildTools }

                FrameworksQuestion ->
                    { answerMap | frameworks = removeGroup answerMap.frameworks }

                EditorsQuestion ->
                    { answerMap | editors = removeGroup answerMap.editors }

                TestToolsQuestion ->
                    { answerMap | testTools = removeGroup answerMap.testTools }

                ElmInitialInterestQuestion ->
                    { answerMap | elmInitialInterest = removeGroup_ answerMap.elmInitialInterest }

                BiggestPainPointQuestion ->
                    { answerMap | biggestPainPoint = removeGroup_ answerMap.biggestPainPoint }

                WhatDoYouLikeMostQuestion ->
                    { answerMap | whatDoYouLikeMost = removeGroup_ answerMap.whatDoYouLikeMost }

                DoYouUseElmQuestion ->
                    answerMap

                AgeQuestion ->
                    answerMap

                FunctionalProgrammingExperienceQuestion ->
                    answerMap

                CountryLivingInQuestion ->
                    answerMap

                DoYouUseElmAtWorkQuestion ->
                    answerMap

                HowLargeIsTheCompanyQuestion ->
                    answerMap

                HowLongQuestion ->
                    answerMap

                DoYouUseElmFormatQuestion ->
                    answerMap

                DoYouUseElmReviewQuestion ->
                    answerMap

                PleaseSelectYourGenderQuestion ->
                    answerMap

                WhatPreventsYouFromUsingElmAtWork ->
                    { answerMap | whatPreventsYouFromUsingElmAtWork = removeGroup_ answerMap.whatPreventsYouFromUsingElmAtWork }

                HowDidItGoUsingElmAtWork ->
                    { answerMap | howDidItGoUsingElmAtWork = removeGroup_ answerMap.howDidItGoUsingElmAtWork }

                SurveyImprovementsQuestion ->
                    answerMap

                WhatPackagesDoYouUseQuestion ->
                    answerMap

        TypedGroupName question hotkey groupName ->
            let
                renameGroup : AnswerMap a -> AnswerMap a
                renameGroup =
                    AnswerMap.renameGroup hotkey groupName

                renameGroup_ : FreeTextAnswerMap -> FreeTextAnswerMap
                renameGroup_ =
                    FreeTextAnswerMap.renameGroup hotkey groupName
            in
            case question of
                OtherLanguagesQuestion ->
                    { answerMap | otherLanguages = renameGroup answerMap.otherLanguages }

                NewsAndDiscussionsQuestion ->
                    { answerMap | newsAndDiscussions = renameGroup answerMap.newsAndDiscussions }

                ElmResourcesQuestion ->
                    { answerMap | elmResources = renameGroup answerMap.elmResources }

                ApplicationDomainsQuestion ->
                    { answerMap | applicationDomains = renameGroup answerMap.applicationDomains }

                WhatLanguageDoYouUseForBackendQuestion ->
                    { answerMap | whatLanguageDoYouUseForBackend = renameGroup answerMap.whatLanguageDoYouUseForBackend }

                ElmVersionQuestion ->
                    { answerMap | elmVersion = renameGroup answerMap.elmVersion }

                StylingToolsQuestion ->
                    { answerMap | stylingTools = renameGroup answerMap.stylingTools }

                BuildToolsQuestion ->
                    { answerMap | buildTools = renameGroup answerMap.buildTools }

                FrameworksQuestion ->
                    { answerMap | frameworks = renameGroup answerMap.frameworks }

                EditorsQuestion ->
                    { answerMap | editors = renameGroup answerMap.editors }

                TestToolsQuestion ->
                    { answerMap | testTools = renameGroup answerMap.testTools }

                ElmInitialInterestQuestion ->
                    { answerMap | elmInitialInterest = renameGroup_ answerMap.elmInitialInterest }

                BiggestPainPointQuestion ->
                    { answerMap | biggestPainPoint = renameGroup_ answerMap.biggestPainPoint }

                WhatDoYouLikeMostQuestion ->
                    { answerMap | whatDoYouLikeMost = renameGroup_ answerMap.whatDoYouLikeMost }

                DoYouUseElmQuestion ->
                    answerMap

                AgeQuestion ->
                    answerMap

                FunctionalProgrammingExperienceQuestion ->
                    answerMap

                CountryLivingInQuestion ->
                    answerMap

                DoYouUseElmAtWorkQuestion ->
                    answerMap

                HowLargeIsTheCompanyQuestion ->
                    answerMap

                HowLongQuestion ->
                    answerMap

                DoYouUseElmFormatQuestion ->
                    answerMap

                DoYouUseElmReviewQuestion ->
                    answerMap

                PleaseSelectYourGenderQuestion ->
                    answerMap

                WhatPreventsYouFromUsingElmAtWork ->
                    { answerMap | whatPreventsYouFromUsingElmAtWork = renameGroup_ answerMap.whatPreventsYouFromUsingElmAtWork }

                HowDidItGoUsingElmAtWork ->
                    { answerMap | howDidItGoUsingElmAtWork = renameGroup_ answerMap.howDidItGoUsingElmAtWork }

                SurveyImprovementsQuestion ->
                    answerMap

                WhatPackagesDoYouUseQuestion ->
                    answerMap

        TypedNewGroupName question groupName ->
            let
                addGroup : AnswerMap a -> AnswerMap a
                addGroup =
                    AnswerMap.addGroup groupName

                addGroup_ : FreeTextAnswerMap -> FreeTextAnswerMap
                addGroup_ =
                    FreeTextAnswerMap.addGroup groupName
            in
            case question of
                OtherLanguagesQuestion ->
                    { answerMap | otherLanguages = addGroup answerMap.otherLanguages }

                NewsAndDiscussionsQuestion ->
                    { answerMap | newsAndDiscussions = addGroup answerMap.newsAndDiscussions }

                ElmResourcesQuestion ->
                    { answerMap | elmResources = addGroup answerMap.elmResources }

                ApplicationDomainsQuestion ->
                    { answerMap | applicationDomains = addGroup answerMap.applicationDomains }

                WhatLanguageDoYouUseForBackendQuestion ->
                    { answerMap | whatLanguageDoYouUseForBackend = addGroup answerMap.whatLanguageDoYouUseForBackend }

                ElmVersionQuestion ->
                    { answerMap | elmVersion = addGroup answerMap.elmVersion }

                StylingToolsQuestion ->
                    { answerMap | stylingTools = addGroup answerMap.stylingTools }

                BuildToolsQuestion ->
                    { answerMap | buildTools = addGroup answerMap.buildTools }

                FrameworksQuestion ->
                    { answerMap | frameworks = addGroup answerMap.frameworks }

                EditorsQuestion ->
                    { answerMap | editors = addGroup answerMap.editors }

                TestToolsQuestion ->
                    { answerMap | testTools = addGroup answerMap.testTools }

                ElmInitialInterestQuestion ->
                    { answerMap | elmInitialInterest = addGroup_ answerMap.elmInitialInterest }

                BiggestPainPointQuestion ->
                    { answerMap | biggestPainPoint = addGroup_ answerMap.biggestPainPoint }

                WhatDoYouLikeMostQuestion ->
                    { answerMap | whatDoYouLikeMost = addGroup_ answerMap.whatDoYouLikeMost }

                DoYouUseElmQuestion ->
                    answerMap

                AgeQuestion ->
                    answerMap

                FunctionalProgrammingExperienceQuestion ->
                    answerMap

                CountryLivingInQuestion ->
                    answerMap

                DoYouUseElmAtWorkQuestion ->
                    answerMap

                HowLargeIsTheCompanyQuestion ->
                    answerMap

                HowLongQuestion ->
                    answerMap

                DoYouUseElmFormatQuestion ->
                    answerMap

                DoYouUseElmReviewQuestion ->
                    answerMap

                PleaseSelectYourGenderQuestion ->
                    answerMap

                WhatPreventsYouFromUsingElmAtWork ->
                    { answerMap | whatPreventsYouFromUsingElmAtWork = addGroup_ answerMap.whatPreventsYouFromUsingElmAtWork }

                HowDidItGoUsingElmAtWork ->
                    { answerMap | howDidItGoUsingElmAtWork = addGroup_ answerMap.howDidItGoUsingElmAtWork }

                SurveyImprovementsQuestion ->
                    answerMap

                WhatPackagesDoYouUseQuestion ->
                    answerMap

        TypedOtherAnswerGroups question otherAnswer text ->
            let
                updateOtherAnswer : AnswerMap a -> AnswerMap a
                updateOtherAnswer =
                    AnswerMap.updateOtherAnswer
                        (String.toList text |> List.map AnswerMap.hotkey)
                        otherAnswer

                updateOtherAnswer_ : FreeTextAnswerMap -> FreeTextAnswerMap
                updateOtherAnswer_ =
                    FreeTextAnswerMap.updateOtherAnswer
                        (String.toList text |> List.map AnswerMap.hotkey)
                        otherAnswer
            in
            case question of
                OtherLanguagesQuestion ->
                    { answerMap | otherLanguages = updateOtherAnswer answerMap.otherLanguages }

                NewsAndDiscussionsQuestion ->
                    { answerMap | newsAndDiscussions = updateOtherAnswer answerMap.newsAndDiscussions }

                ElmResourcesQuestion ->
                    { answerMap | elmResources = updateOtherAnswer answerMap.elmResources }

                ApplicationDomainsQuestion ->
                    { answerMap | applicationDomains = updateOtherAnswer answerMap.applicationDomains }

                WhatLanguageDoYouUseForBackendQuestion ->
                    { answerMap | whatLanguageDoYouUseForBackend = updateOtherAnswer answerMap.whatLanguageDoYouUseForBackend }

                ElmVersionQuestion ->
                    { answerMap | elmVersion = updateOtherAnswer answerMap.elmVersion }

                StylingToolsQuestion ->
                    { answerMap | stylingTools = updateOtherAnswer answerMap.stylingTools }

                BuildToolsQuestion ->
                    { answerMap | buildTools = updateOtherAnswer answerMap.buildTools }

                FrameworksQuestion ->
                    { answerMap | frameworks = updateOtherAnswer answerMap.frameworks }

                EditorsQuestion ->
                    { answerMap | editors = updateOtherAnswer answerMap.editors }

                TestToolsQuestion ->
                    { answerMap | testTools = updateOtherAnswer answerMap.testTools }

                ElmInitialInterestQuestion ->
                    { answerMap | elmInitialInterest = updateOtherAnswer_ answerMap.elmInitialInterest }

                BiggestPainPointQuestion ->
                    { answerMap | biggestPainPoint = updateOtherAnswer_ answerMap.biggestPainPoint }

                WhatDoYouLikeMostQuestion ->
                    { answerMap | whatDoYouLikeMost = updateOtherAnswer_ answerMap.whatDoYouLikeMost }

                DoYouUseElmQuestion ->
                    answerMap

                AgeQuestion ->
                    answerMap

                FunctionalProgrammingExperienceQuestion ->
                    answerMap

                CountryLivingInQuestion ->
                    answerMap

                DoYouUseElmAtWorkQuestion ->
                    answerMap

                HowLargeIsTheCompanyQuestion ->
                    answerMap

                HowLongQuestion ->
                    answerMap

                DoYouUseElmFormatQuestion ->
                    answerMap

                DoYouUseElmReviewQuestion ->
                    answerMap

                PleaseSelectYourGenderQuestion ->
                    answerMap

                WhatPreventsYouFromUsingElmAtWork ->
                    { answerMap | whatPreventsYouFromUsingElmAtWork = updateOtherAnswer_ answerMap.whatPreventsYouFromUsingElmAtWork }

                HowDidItGoUsingElmAtWork ->
                    { answerMap | howDidItGoUsingElmAtWork = updateOtherAnswer_ answerMap.howDidItGoUsingElmAtWork }

                SurveyImprovementsQuestion ->
                    answerMap

                WhatPackagesDoYouUseQuestion ->
                    answerMap

        TypedComment question text ->
            let
                withComment : AnswerMap a -> AnswerMap a
                withComment =
                    AnswerMap.withComment text

                withComment_ : FreeTextAnswerMap -> FreeTextAnswerMap
                withComment_ =
                    FreeTextAnswerMap.withComment text
            in
            case question of
                OtherLanguagesQuestion ->
                    { answerMap | otherLanguages = withComment answerMap.otherLanguages }

                NewsAndDiscussionsQuestion ->
                    { answerMap | newsAndDiscussions = withComment answerMap.newsAndDiscussions }

                ElmResourcesQuestion ->
                    { answerMap | elmResources = withComment answerMap.elmResources }

                ApplicationDomainsQuestion ->
                    { answerMap | applicationDomains = withComment answerMap.applicationDomains }

                WhatLanguageDoYouUseForBackendQuestion ->
                    { answerMap | whatLanguageDoYouUseForBackend = withComment answerMap.whatLanguageDoYouUseForBackend }

                ElmVersionQuestion ->
                    { answerMap | elmVersion = withComment answerMap.elmVersion }

                StylingToolsQuestion ->
                    { answerMap | stylingTools = withComment answerMap.stylingTools }

                BuildToolsQuestion ->
                    { answerMap | buildTools = withComment answerMap.buildTools }

                FrameworksQuestion ->
                    { answerMap | frameworks = withComment answerMap.frameworks }

                EditorsQuestion ->
                    { answerMap | editors = withComment answerMap.editors }

                TestToolsQuestion ->
                    { answerMap | testTools = withComment answerMap.testTools }

                ElmInitialInterestQuestion ->
                    { answerMap | elmInitialInterest = withComment_ answerMap.elmInitialInterest }

                BiggestPainPointQuestion ->
                    { answerMap | biggestPainPoint = withComment_ answerMap.biggestPainPoint }

                WhatDoYouLikeMostQuestion ->
                    { answerMap | whatDoYouLikeMost = withComment_ answerMap.whatDoYouLikeMost }

                DoYouUseElmQuestion ->
                    { answerMap | doYouUseElm = text }

                AgeQuestion ->
                    { answerMap | age = text }

                FunctionalProgrammingExperienceQuestion ->
                    { answerMap | functionalProgrammingExperience = text }

                CountryLivingInQuestion ->
                    { answerMap | countryLivingIn = text }

                DoYouUseElmAtWorkQuestion ->
                    { answerMap | doYouUseElmAtWork = text }

                HowLargeIsTheCompanyQuestion ->
                    { answerMap | howLargeIsTheCompany = text }

                HowLongQuestion ->
                    { answerMap | howLong = text }

                DoYouUseElmFormatQuestion ->
                    { answerMap | doYouUseElmFormat = text }

                DoYouUseElmReviewQuestion ->
                    { answerMap | doYouUseElmReview = text }

                PleaseSelectYourGenderQuestion ->
                    { answerMap | pleaseSelectYourGender = text }

                WhatPreventsYouFromUsingElmAtWork ->
                    { answerMap | whatPreventsYouFromUsingElmAtWork = withComment_ answerMap.whatPreventsYouFromUsingElmAtWork }

                HowDidItGoUsingElmAtWork ->
                    { answerMap | howDidItGoUsingElmAtWork = withComment_ answerMap.howDidItGoUsingElmAtWork }

                SurveyImprovementsQuestion ->
                    answerMap

                WhatPackagesDoYouUseQuestion ->
                    { answerMap | whatPackagesDoYouUse = text }


update : Msg -> Model -> ( Model, Command FrontendOnly ToBackend Msg )
update msg model =
    case msg of
        TypedFormsData text ->
            if Env.isProduction then
                ( model, Command.none )

            else
                case Serialize.decodeFromString codec text of
                    Ok ( forms, formMapping ) ->
                        ( { model
                            | forms =
                                List.map
                                    (\form -> { form = form, submitTime = Just (Effect.Time.millisToPosix 0) })
                                    forms
                            , formMapping = NetworkModel.init formMapping
                          }
                        , ReplaceFormsRequest ( forms, formMapping ) |> Lamdera.sendToBackend
                        )

                    Err _ ->
                        ( model, Command.none )

        PressedLogOut ->
            ( model, Lamdera.sendToBackend LogOutRequest )

        PressedQuestionWithOther questionWithOther ->
            ( { model | selectedMapping = questionWithOther }, Command.none )

        PressedToggleShowEncodedState ->
            ( { model | showEncodedState = not model.showEncodedState }, Command.none )

        FormMappingEditMsg edit ->
            ( { model | formMapping = NetworkModel.updateFromUser edit model.formMapping }
            , Lamdera.sendToBackend (EditFormMappingRequest edit)
            )

        NoOp ->
            ( model, Command.none )

        PressedSendEmails ->
            case model.sendEmailsStatus of
                EmailsNotSent ->
                    ( { model | sendEmailsStatus = Sending }, Lamdera.sendToBackend SendEmailsRequest )

                Sending ->
                    ( model, Command.none )

                SendResult _ ->
                    ( model, Command.none )

        PressedAiCategorization specificQuestion ->
            ( { model
                | aiCategorization =
                    AssocList.insert specificQuestion AiCategorizationInProgress model.aiCategorization
              }
            , Lamdera.sendToBackend (AiCategorizationRequest specificQuestion)
            )

        SurveyMsg surveyMsg ->
            case surveyMsg of
                SurveyResults2023.PressedModeButton mode ->
                    ( { model | resultMode = mode }, Command.none )

                SurveyResults2023.PressedSegmentButton segment ->
                    ( { model | resultSegment = segment }, Command.none )

                SurveyResults2023.PressedPackageModeButton packageMode ->
                    ( { model | resultPackageMode = packageMode }, Command.none )


type AiCategorizationStatus
    = AiCategorizationInProgress
    | AiCategorizationReady (Dict String (Set String))


button : Bool -> msg -> String -> Element msg
button isSelected onPress text =
    Element.Input.button
        [ Element.Background.color
            (if isSelected then
                Ui.blue1

             else
                Ui.white
            )
        , Element.Font.color Ui.black
        , Element.Font.bold
        , Element.padding 8
        , Element.Border.width 1
        , Element.Font.size 16
        ]
        { onPress = Just onPress
        , label = Element.text text
        }


deleteButton : msg -> Element msg
deleteButton onPress =
    Element.Input.button
        [ Element.Font.color Ui.black
        , Element.Font.bold
        , Element.paddingXY 6 4
        , Element.Border.width 1
        ]
        { onPress = Just onPress
        , label = Element.text "X"
        }


codec : Serialize.Codec e ( List Form2023, FormMapping )
codec =
    Serialize.tuple (Serialize.list Form2023.formCodec) Form2023.formMappingCodec


adminView : Model -> Element Msg
adminView model =
    Element.column
        [ Element.spacing 32, Element.padding 16 ]
        [ Element.row
            [ Element.Font.size 36 ]
            [ Element.text "Admin view "
            , if Env.isProduction then
                Element.el [ Element.Font.color (Element.rgb 0.8 0 0) ] (Element.text "(PRODUCTION)")

              else
                Element.text "(development)"
            ]
        , Element.row [ Element.spacing 16 ]
            [ button False PressedLogOut "Log out"
            , button model.showEncodedState PressedToggleShowEncodedState "Show encoded state"
            , if Env.canShowLatestResults then
                case model.sendEmailsStatus of
                    EmailsNotSent ->
                        button False PressedSendEmails "Email survey results"

                    Sending ->
                        button False PressedSendEmails "Sending..."

                    SendResult list ->
                        List.filterMap
                            (\{ emailAddress, result } ->
                                case result of
                                    Ok _ ->
                                        Nothing

                                    Err _ ->
                                        Just (EmailAddress.toString emailAddress)
                            )
                            list
                            |> String.join ", "
                            |> (++) "Failed to send 1 or more emails: "
                            |> Element.text
                            |> List.singleton
                            |> Element.paragraph []

              else
                Element.none
            , Element.text (String.fromInt (List.length model.forms) ++ " submissions")
            ]
        , if model.showEncodedState then
            Element.Input.text
                []
                { onChange = TypedFormsData
                , text =
                    ( List.filterMap
                        (\{ form, submitTime } ->
                            case submitTime of
                                Just _ ->
                                    Just form

                                Nothing ->
                                    Nothing
                        )
                        model.forms
                    , NetworkModel.localState networkUpdate model.formMapping
                    )
                        |> Serialize.encodeToString codec
                , placeholder = Nothing
                , label = Element.Input.labelHidden ""
                }

          else
            Element.none
        , List.map
            (\question ->
                button
                    (model.selectedMapping == question)
                    (PressedQuestionWithOther question)
                    (questionName question)
            )
            allQuestions
            |> Element.wrappedRow []
        , answerMapView model

        --, Element.column
        --    [ Element.spacing 32 ]
        --    (List.map adminFormView model.forms)
        ]


updateFromBackend : ToFrontend -> Model -> Model
updateFromBackend toFrontend model =
    case toFrontend of
        EditFormMappingResponse formMappingEdit ->
            { model | formMapping = NetworkModel.updateFromBackend networkUpdate formMappingEdit model.formMapping }

        SendEmailsResponse list ->
            { model | sendEmailsStatus = SendResult list }


answerMapView : Model -> Element Msg
answerMapView model =
    let
        formMapping : FormMapping
        formMapping =
            NetworkModel.localState networkUpdate model.formMapping
    in
    case model.selectedMapping of
        OtherLanguagesQuestion ->
            answerMappingView
                model.selectedMapping
                True
                Questions.otherLanguages
                .otherLanguages
                formMapping.otherLanguages
                model

        NewsAndDiscussionsQuestion ->
            answerMappingView
                model.selectedMapping
                False
                Questions.newsAndDiscussions
                .newsAndDiscussions
                formMapping.newsAndDiscussions
                model

        ElmResourcesQuestion ->
            answerMappingView
                model.selectedMapping
                False
                Questions.elmResources
                .elmResources
                formMapping.elmResources
                model

        ApplicationDomainsQuestion ->
            answerMappingView
                model.selectedMapping
                False
                Questions.applicationDomains
                .applicationDomains
                formMapping.applicationDomains
                model

        WhatLanguageDoYouUseForBackendQuestion ->
            answerMappingView
                model.selectedMapping
                True
                Questions.whatLanguageDoYouUseForBackend
                .whatLanguageDoYouUseForBackend
                formMapping.whatLanguageDoYouUseForBackend
                model

        ElmVersionQuestion ->
            answerMappingView
                model.selectedMapping
                False
                Questions.elmVersion
                .elmVersion
                formMapping.elmVersion
                model

        StylingToolsQuestion ->
            answerMappingView
                model.selectedMapping
                False
                Questions.stylingTools
                .stylingTools
                formMapping.stylingTools
                model

        BuildToolsQuestion ->
            answerMappingView
                model.selectedMapping
                False
                Questions.buildTools
                .buildTools
                formMapping.buildTools
                model

        FrameworksQuestion ->
            answerMappingView
                model.selectedMapping
                False
                Questions.frameworks
                .frameworks
                formMapping.frameworks
                model

        EditorsQuestion ->
            answerMappingView
                model.selectedMapping
                False
                Questions.editors
                .editors
                formMapping.editors
                model

        TestToolsQuestion ->
            answerMappingView
                model.selectedMapping
                False
                Questions.testTools
                .testTools
                formMapping.testTools
                model

        ElmInitialInterestQuestion ->
            freeTextMappingView
                model.selectedMapping
                Questions.initialInterestTitle
                .elmInitialInterest
                formMapping.elmInitialInterest
                (AssocList.get ElmInitialInterestQuestion model.aiCategorization)
                model

        BiggestPainPointQuestion ->
            freeTextMappingView
                model.selectedMapping
                Questions.biggestPainPointTitle
                .biggestPainPoint
                formMapping.biggestPainPoint
                (AssocList.get BiggestPainPointQuestion model.aiCategorization)
                model

        WhatDoYouLikeMostQuestion ->
            freeTextMappingView
                model.selectedMapping
                Questions.whatDoYouLikeMostTitle
                .whatDoYouLikeMost
                formMapping.whatDoYouLikeMost
                (AssocList.get WhatDoYouLikeMostQuestion model.aiCategorization)
                model

        DoYouUseElmQuestion ->
            answerMappingView
                model.selectedMapping
                False
                Questions.doYouUseElm
                (\a -> { choices = a.doYouUseElm, otherChecked = False, otherText = "" })
                (AnswerMap.init Questions.doYouUseElm |> AnswerMap.withComment formMapping.doYouUseElm)
                model

        AgeQuestion ->
            commentEditor
                model.selectedMapping
                False
                Questions.age
                .age
                formMapping.age
                model

        FunctionalProgrammingExperienceQuestion ->
            commentEditor
                model.selectedMapping
                False
                Questions.experienceLevel
                .functionalProgrammingExperience
                formMapping.functionalProgrammingExperience
                model

        CountryLivingInQuestion ->
            commentEditor
                model.selectedMapping
                True
                Questions.countryLivingIn
                .countryLivingIn
                formMapping.countryLivingIn
                model

        DoYouUseElmAtWorkQuestion ->
            commentEditor
                model.selectedMapping
                False
                Questions.doYouUseElmAtWork
                .doYouUseElmAtWork
                formMapping.doYouUseElmAtWork
                model

        HowLargeIsTheCompanyQuestion ->
            commentEditor
                model.selectedMapping
                False
                Questions.howLargeIsTheCompany
                .howLargeIsTheCompany
                formMapping.howLargeIsTheCompany
                model

        HowLongQuestion ->
            commentEditor
                model.selectedMapping
                False
                Questions.howLong
                .howLong
                formMapping.howLong
                model

        DoYouUseElmFormatQuestion ->
            commentEditor
                model.selectedMapping
                False
                Questions.doYouUseElmFormat
                .doYouUseElmFormat
                formMapping.doYouUseElmFormat
                model

        DoYouUseElmReviewQuestion ->
            commentEditor
                model.selectedMapping
                False
                Questions.doYouUseElmReview
                .doYouUseElmReview
                formMapping.doYouUseElmReview
                model

        PleaseSelectYourGenderQuestion ->
            commentEditor
                model.selectedMapping
                False
                Questions.pleaseSelectYourGender
                .pleaseSelectYourGender
                formMapping.pleaseSelectYourGender
                model

        WhatPreventsYouFromUsingElmAtWork ->
            freeTextMappingView
                model.selectedMapping
                Questions.whatPreventsYouFromUsingElmAtWorkTitle
                .whatPreventsYouFromUsingElmAtWork
                formMapping.whatPreventsYouFromUsingElmAtWork
                (AssocList.get WhatPreventsYouFromUsingElmAtWork model.aiCategorization)
                model

        HowDidItGoUsingElmAtWork ->
            freeTextMappingView
                model.selectedMapping
                Questions.howDidItGoUsingElmAtWorkTitle
                .howDidItGoUsingElmAtWork
                formMapping.howDidItGoUsingElmAtWork
                (AssocList.get HowDidItGoUsingElmAtWork model.aiCategorization)
                model

        SurveyImprovementsQuestion ->
            submittedForms model.forms
                |> List.map (\form -> Element.paragraph [] [ Element.text form.surveyImprovements ])
                |> Element.column [ Element.width Element.fill, Element.spacing 16 ]

        WhatPackagesDoYouUseQuestion ->
            let
                forms =
                    submittedForms model.forms
            in
            Element.row
                [ Element.spacing 8, Element.width Element.fill ]
                [ Element.Input.multiline
                    [ Element.width Element.fill, Element.alignTop ]
                    { onChange = TypedComment WhatPackagesDoYouUseQuestion >> FormMappingEditMsg
                    , text = formMapping.whatPackagesDoYouUse
                    , placeholder = Nothing
                    , label = Element.Input.labelAbove [] (Element.text "Comment")
                    , spellcheck = True
                    }
                , SurveyResults2023.packageQuestionView
                    { width = 1920, height = 1080 }
                    model.resultPackageMode
                    { packageUsageGroupedByAuthor = groupPackagesBy .author forms
                    , packageUsageGroupedByName = groupPackagesBy (\a -> ( a.author, a.name )) forms
                    , packageUsageGroupedByMajorVersion =
                        groupPackagesBy (\a -> ( a.author, a.name, a.majorVersion )) forms
                    }
                    |> Element.map SurveyMsg
                ]


groupPackagesBy :
    (PackageName -> comparable)
    -> List { b | elmJson : List (List PackageName) }
    -> Dict.Dict comparable number
groupPackagesBy groupBy forms =
    List.foldl
        (\form state ->
            List.concat form.elmJson
                |> List.map groupBy
                |> Set.fromList
                |> Set.toList
                |> List.foldl
                    (\key state2 -> Dict.update key (\a -> a |> Maybe.withDefault 0 |> (+) 1 |> Just) state2)
                    state
        )
        Dict.empty
        forms


questionName : SpecificQuestion -> String
questionName selectedMapping =
    case selectedMapping of
        OtherLanguagesQuestion ->
            "OtherLanguages"

        NewsAndDiscussionsQuestion ->
            "NewsAndDiscussions"

        ElmResourcesQuestion ->
            "ElmResources"

        ApplicationDomainsQuestion ->
            "ApplicationDomains"

        WhatLanguageDoYouUseForBackendQuestion ->
            "WhatLanguageDoYouUseForBackend"

        ElmVersionQuestion ->
            "ElmVersion"

        StylingToolsQuestion ->
            "StylingTools"

        BuildToolsQuestion ->
            "BuildTools"

        FrameworksQuestion ->
            "Frameworks"

        EditorsQuestion ->
            "Editors"

        TestToolsQuestion ->
            "TestTools"

        ElmInitialInterestQuestion ->
            "ElmInitialInterest"

        BiggestPainPointQuestion ->
            "BiggestPainPoint"

        WhatDoYouLikeMostQuestion ->
            "WhatDoYouLikeMost"

        DoYouUseElmQuestion ->
            "DoYouUseElm"

        AgeQuestion ->
            "Age"

        FunctionalProgrammingExperienceQuestion ->
            "FunctionalProgrammingExperience"

        CountryLivingInQuestion ->
            "CountryLivingIn"

        DoYouUseElmAtWorkQuestion ->
            "DoYouUseElmAtWork"

        HowLargeIsTheCompanyQuestion ->
            "HowLargeIsTheCompany"

        HowLongQuestion ->
            "HowLong"

        DoYouUseElmFormatQuestion ->
            "DoYouUseElmFormat"

        DoYouUseElmReviewQuestion ->
            "DoYouUseElmReview"

        PleaseSelectYourGenderQuestion ->
            "PleaseSelectYourGender"

        WhatPreventsYouFromUsingElmAtWork ->
            "WhatPreventsYouFromUsingElmAtWork"

        HowDidItGoUsingElmAtWork ->
            "HowDidItGoUsingElmAtWork"

        SurveyImprovementsQuestion ->
            "SurveyImprovements"

        WhatPackagesDoYouUseQuestion ->
            "WhatPackagesDoYouUse"


commentEditor : SpecificQuestion -> Bool -> Question a -> (Form2023 -> Maybe a) -> String -> Model -> Element Msg
commentEditor specificQuestion singleLine question getAnswer comment model =
    let
        answers : List a
        answers =
            submittedForms model.forms |> List.map getAnswer |> List.filterMap identity
    in
    Element.row [ Element.spacing 8, Element.width Element.fill ]
        [ Element.Input.multiline
            [ Element.width Element.fill, Element.alignTop ]
            { onChange = TypedComment specificQuestion >> FormMappingEditMsg
            , text = comment
            , placeholder = Nothing
            , label = Element.Input.labelAbove [] (Element.text "Comment")
            , spellcheck = True
            }
        , SurveyResults2023.singleChoiceGraph
            { width = 1920, height = 1080 }
            singleLine
            True
            model.resultMode
            (DataEntry.fromForms comment question.choices answers)
            question
            |> Element.map (\_ -> NoOp)
        ]


aiCategorizationButtonId : HtmlId
aiCategorizationButtonId =
    Dom.id "adminPage_aiCategorizationButton"


categorizeWithAiButton specificQuestion =
    Ui.button aiCategorizationButtonId (PressedAiCategorization specificQuestion) "Categorize with AI"


freeTextMappingView :
    SpecificQuestion
    -> String
    -> (Form2023 -> String)
    -> FreeTextAnswerMap
    -> Maybe AiCategorizationStatus
    -> Model
    -> Element Msg
freeTextMappingView specificQuestion title getAnswer answerMap aiCategorizations model =
    let
        answers : List String
        answers =
            submittedForms model.forms
                |> List.map getAnswer

        filtered =
            List.filterMap Form2023.getOtherAnswer_ answers

        aiCategories : Dict String (Set String)
        aiCategories =
            case aiCategorizations of
                Just (AiCategorizationReady dict) ->
                    Dict.map
                        (\_ groups ->
                            List.filterMap
                                (\group ->
                                    if Set.member group.groupName groups then
                                        AnswerMap.hotkeyToString group.hotkey |> Just

                                    else
                                        Nothing
                                )
                                allGroups
                                |> Set.fromList
                        )
                        dict

                _ ->
                    Dict.empty

        allGroups : List { hotkey : Hotkey, editable : Bool, groupName : String }
        allGroups =
            FreeTextAnswerMap.allGroups answerMap
    in
    Element.row
        [ Element.spacing 24, Element.width Element.fill ]
        [ Element.column
            [ Element.alignTop, Element.spacing 16 ]
            [ Element.text (questionName model.selectedMapping)
            , Element.text ("Number of responses: " ++ String.fromInt (List.length filtered))
            , case aiCategorizations of
                Just AiCategorizationInProgress ->
                    Element.text "Categorization in progress..."

                Just (AiCategorizationReady _) ->
                    categorizeWithAiButton specificQuestion

                Nothing ->
                    categorizeWithAiButton specificQuestion
            , Element.column
                [ Element.spacing 8 ]
                (List.map
                    (\{ groupName, hotkey, editable } ->
                        Element.row [ Element.spacing 8 ]
                            [ Element.el
                                [ Element.Font.italic ]
                                (Element.text ("(" ++ AnswerMap.hotkeyToString hotkey ++ ")"))
                            , if editable then
                                Element.Input.text
                                    [ Element.width (Element.px 400), Element.paddingXY 4 6 ]
                                    { text = groupName
                                    , onChange = TypedGroupName specificQuestion hotkey >> FormMappingEditMsg
                                    , placeholder = Nothing
                                    , label = Element.Input.labelHidden "mapTo"
                                    }

                              else
                                Element.text groupName
                            , if editable then
                                deleteButton (RemoveGroup specificQuestion hotkey |> FormMappingEditMsg)

                              else
                                Element.none
                            ]
                    )
                    allGroups
                    ++ [ Element.row []
                            [ Element.el [ Element.Font.italic ] (Element.text "( ) ")
                            , Element.Input.text
                                [ Element.width (Element.px 400), Element.paddingXY 4 6 ]
                                { text = ""
                                , onChange = TypedNewGroupName specificQuestion >> FormMappingEditMsg
                                , placeholder = Nothing
                                , label = Element.Input.labelHidden "Group"
                                }
                            ]
                       ]
                )
            ]
        , Element.column
            [ Element.width Element.fill, Element.spacing 16 ]
            [ List.sortBy AnswerMap.normalizeOtherAnswer filtered
                |> List.map
                    (\other ->
                        let
                            otherAnswer : OtherAnswer
                            otherAnswer =
                                AnswerMap.otherAnswer other
                        in
                        Element.row
                            [ Element.spacing 4 ]
                            [ Element.Input.text
                                [ Element.width (Element.px 80), Element.paddingXY 4 6 ]
                                { text =
                                    FreeTextAnswerMap.otherAnswerMapsTo otherAnswer answerMap
                                        |> List.map (.hotkey >> AnswerMap.hotkeyToString)
                                        |> String.concat
                                , onChange =
                                    TypedOtherAnswerGroups specificQuestion otherAnswer
                                        >> FormMappingEditMsg
                                , placeholder =
                                    case Dict.get (AnswerMap.normalizeOtherAnswer other) aiCategories of
                                        Just categories ->
                                            Set.toList categories
                                                |> String.concat
                                                |> Element.text
                                                |> Element.Input.placeholder []
                                                |> Just

                                        Nothing ->
                                            Nothing
                                , label = Element.Input.labelHidden "New group"
                                }
                            , Element.paragraph [ Element.spacing 2 ] [ Element.text other ]
                            ]
                    )
                |> Element.column
                    [ Element.spacing 8
                    , Element.width Element.fill
                    , Element.scrollbars
                    , Element.height (Element.px 600)
                    , Element.alignTop
                    , Element.Border.width 1
                    , Element.padding 16
                    ]
            , Element.Input.multiline
                [ Element.width Element.fill ]
                { onChange = TypedComment specificQuestion >> FormMappingEditMsg
                , text = FreeTextAnswerMap.comment answerMap
                , placeholder = Nothing
                , label = Element.Input.labelAbove [] (Element.text "Comment")
                , spellcheck = True
                }
            ]
        , SurveyResults2023.freeText
            model.resultMode
            { width = 1920, height = 1080 }
            (DataEntry.fromFreeText answerMap answers)
            title
            |> Element.map (\_ -> NoOp)
        ]


answerMappingView :
    SpecificQuestion
    -> Bool
    -> Question a
    -> (Form2023 -> MultiChoiceWithOther a)
    -> AnswerMap a
    -> Model
    -> Element Msg
answerMappingView specificQuestion singleLine question getAnswer answerMap model =
    let
        answers : List (MultiChoiceWithOther a)
        answers =
            submittedForms model.forms |> List.map getAnswer
    in
    Element.row
        [ Element.spacing 24, Element.width Element.fill ]
        [ Element.column
            [ Element.alignTop, Element.spacing 16 ]
            [ Element.text (questionName model.selectedMapping)
            , Element.column
                [ Element.spacing 8 ]
                (List.map
                    (\{ groupName, hotkey, editable } ->
                        Element.row [ Element.spacing 8 ]
                            [ Element.el
                                [ Element.Font.italic ]
                                (Element.text ("(" ++ AnswerMap.hotkeyToString hotkey ++ ")"))
                            , if editable then
                                Element.Input.text
                                    [ Element.width (Element.px 200), Element.paddingXY 4 6 ]
                                    { text = groupName
                                    , onChange = TypedGroupName specificQuestion hotkey >> FormMappingEditMsg
                                    , placeholder = Nothing
                                    , label = Element.Input.labelHidden "mapTo"
                                    }

                              else
                                Element.text groupName
                            , if editable then
                                deleteButton (RemoveGroup specificQuestion hotkey |> FormMappingEditMsg)

                              else
                                Element.none
                            ]
                    )
                    (AnswerMap.allGroups question answerMap)
                    ++ [ Element.row []
                            [ Element.el [ Element.Font.italic ] (Element.text "( ) ")
                            , Element.Input.text
                                [ Element.width (Element.px 200), Element.paddingXY 4 6 ]
                                { text = ""
                                , onChange = TypedNewGroupName specificQuestion >> FormMappingEditMsg
                                , placeholder = Nothing
                                , label = Element.Input.labelHidden "Group"
                                }
                            ]
                       ]
                )
            ]
        , Element.column
            [ Element.width Element.fill, Element.spacing 16, Element.alignTop ]
            [ List.filterMap Form2023.getOtherAnswer answers
                |> List.sortBy (String.trim >> String.toLower)
                |> List.map
                    (\other ->
                        let
                            otherAnswer : OtherAnswer
                            otherAnswer =
                                AnswerMap.otherAnswer other
                        in
                        Element.row
                            [ Element.spacing 4 ]
                            [ Element.Input.text
                                [ Element.width (Element.px 80), Element.paddingXY 4 6 ]
                                { text =
                                    AnswerMap.otherAnswerMapsTo question otherAnswer answerMap
                                        |> List.map (.hotkey >> AnswerMap.hotkeyToString)
                                        |> String.concat
                                , onChange = TypedOtherAnswerGroups specificQuestion otherAnswer >> FormMappingEditMsg
                                , placeholder = Nothing
                                , label = Element.Input.labelHidden "New group"
                                }
                            , Element.paragraph [ Element.spacing 2 ] [ Element.text other ]
                            ]
                    )
                |> Element.column
                    [ Element.spacing 8
                    , Element.width Element.fill
                    , Element.scrollbars
                    , Element.height (Element.px 600)
                    , Element.alignTop
                    , Element.Border.width 1
                    , Element.padding 16
                    ]
            , Element.Input.multiline
                [ Element.width Element.fill ]
                { onChange = TypedComment specificQuestion >> FormMappingEditMsg
                , text = AnswerMap.comment answerMap
                , placeholder = Nothing
                , label = Element.Input.labelAbove [] (Element.text "Comment")
                , spellcheck = True
                }
            ]
        , SurveyResults2023.multiChoiceWithOther
            { width = 1920, height = 1080 }
            singleLine
            True
            model.resultMode
            (DataEntry.fromMultiChoiceWithOther question answerMap answers)
            question
            |> Element.map SurveyMsg
        ]


submittedForms : List { form : Form2023, submitTime : Maybe Effect.Time.Posix } -> List Form2023
submittedForms forms =
    List.filterMap
        (\{ form, submitTime } ->
            case submitTime of
                Just _ ->
                    Just form

                Nothing ->
                    Nothing
        )
        forms
