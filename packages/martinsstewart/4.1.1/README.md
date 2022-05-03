# SendGrid

This package lets you create and send emails using [SendGrid](https://sendgrid.com/).
Currently only the `/mail/send` API call is supported.
If there is something more you need, [explain your use case here](https://github.com/MartinSStewart/send-grid/issues).

*Note that you cannot use this package to send emails from a browser.
You'll be blocked by CORS.
You need to run this server-side or from a stand alone application.*

## Getting started

### Set up a SendGrid account

Before you can use this package you need a SendGrid API key.
To do this, signup for a SendGrid account.

Then after you've set up your account, click on the settings tab, then API Keys, and finally "Create API Key".
You'll get to choose if the API key has `Full Access`, `Restricted Access`, or `Billing Access`.
For this package it's best if you select restricted access and then set `Mail Send` to `Full Access` and leave everything else as `No Access`.

Once you've done this you'll be given an API key. Store it in a password manager or something for safe keeping. *You are highly recommended to not hard code the API key into your source code!*

### Example code

Once you've completed the previous step you can write something like this to send out emails (again, this will not work in a browser client due to CORS).

```
import SendGrid
import String.Nonempty exposing (NonemptyString)
import List.Nonempty

-- Make sure to install `MartinSStewart/elm-nonempty-string`, `mgold/elm-nonempty-list`, and `tricycle/elm-email`.

email : (Result SendGrid.Error () -> msg) -> Email.Email -> SendGrid.ApiKey -> Cmd msg
email msg recipient apiKey =
    SendGrid.textEmail
        { subject = NonemptyString 'S' "ubject" 
        , to = List.Nonempty.fromElement recipient
        , content = NonemptyString 'H' "i!"
        , nameOfSender = "test name"
        , emailAddressOfSender =
            -- this-can-be-anything@test.com
            { localPart = "this-can-be-anything"
            , tags = []
            , domain = "test"
            , tld = [ "com" ]
            }
        }
        |> SendGrid.sendEmail msg apiKey
```
