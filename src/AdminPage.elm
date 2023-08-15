module AdminPage exposing
    ( AdminLoginData
    , FormMappingEdit(..)
    , Model
    , Msg(..)
    , SendEmailsStatus(..)
    , ToBackend(..)
    , ToFrontend(..)
    , adminView
    , init
    , networkUpdate
    , update
    , updateFromBackend
    )

import AnswerMap exposing (AnswerMap, Hotkey, OtherAnswer)
import DataEntry
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
import NetworkModel exposing (NetworkModel)
import Questions2023 as Questions exposing (Question)
import SendGrid
import Serialize
import SurveyResults2022 exposing (Mode(..))
import Ui exposing (MultiChoiceWithOther)


type Msg
    = PressedLogOut
    | TypedFormsData String
    | FormMappingEditMsg FormMappingEdit
    | PressedQuestionWithOther SpecificQuestion
    | PressedToggleShowEncodedState
    | NoOp
    | PressedSendEmails


type ToBackend
    = ReplaceFormsRequest ( List Form2023, FormMapping )
    | EditFormMappingRequest FormMappingEdit
    | LogOutRequest
    | SendEmailsRequest


type ToFrontend
    = EditFormMappingResponse FormMappingEdit
    | SendEmailsResponse (List { emailAddress : EmailAddress, result : Result SendGrid.Error () })


type alias AdminLoginData =
    { forms : List { form : Form2023, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormMapping
    , sendEmailsStatus : SendEmailsStatus
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
    }


questionsWithOther : List SpecificQuestion
questionsWithOther =
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


codec =
    Serialize.tuple (Serialize.list Form2023.formCodec) Form2023.formMappingCodec


adminView : Model -> Element Msg
adminView model =
    Element.column
        [ Element.spacing 32, Element.padding 16 ]
        [ Element.el [ Element.Font.size 36 ] (Element.text "Admin view")
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
            questionsWithOther
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
                model

        BiggestPainPointQuestion ->
            freeTextMappingView
                model.selectedMapping
                Questions.biggestPainPointTitle
                .biggestPainPoint
                formMapping.biggestPainPoint
                model

        WhatDoYouLikeMostQuestion ->
            freeTextMappingView
                model.selectedMapping
                Questions.whatDoYouLikeMostTitle
                .whatDoYouLikeMost
                formMapping.whatDoYouLikeMost
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
            "PleaseSelectYourGenderQuestion"


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
        , SurveyResults2022.singleChoiceGraph
            { width = 1920, height = 1080 }
            singleLine
            True
            Percentage
            (DataEntry.fromForms comment question.choices answers)
            question
            |> Element.map (\_ -> NoOp)
        ]


freeTextMappingView :
    SpecificQuestion
    -> String
    -> (Form2023 -> String)
    -> FreeTextAnswerMap
    -> Model
    -> Element Msg
freeTextMappingView specificQuestion title getAnswer answerMap model =
    let
        answers : List String
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
                    (FreeTextAnswerMap.allGroups answerMap)
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
            [ List.filterMap Form2023.getOtherAnswer_ answers
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
                                    FreeTextAnswerMap.otherAnswerMapsTo otherAnswer answerMap
                                        |> List.map (.hotkey >> AnswerMap.hotkeyToString)
                                        |> String.concat
                                , onChange =
                                    TypedOtherAnswerGroups specificQuestion otherAnswer
                                        >> FormMappingEditMsg
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
                , text = FreeTextAnswerMap.comment answerMap
                , placeholder = Nothing
                , label = Element.Input.labelAbove [] (Element.text "Comment")
                , spellcheck = True
                }
            ]
        , SurveyResults2022.freeText
            Percentage
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
        , SurveyResults2022.multiChoiceWithOther
            { width = 1920, height = 1080 }
            singleLine
            True
            Percentage
            (DataEntry.fromMultiChoiceWithOther question answerMap answers)
            question
            |> Element.map (\_ -> NoOp)
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
