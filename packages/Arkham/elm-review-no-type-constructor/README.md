# elm-review-no-missing-type-constructor

Provides [`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rules to detect missing type constructors. Shamefully stolen from [this gist](https://gist.github.com/jfmengels/e1fd40af3d0e7bde707c0241bf46920f).

## Provided rules

- [`NoMissingTypeConstructor`](https://package.elm-lang.org/packages/Arkham/elm-review-no-missing-type-constructor/1.0.1/NoMissingTypeConstructor) - Reports missing type constructors.


## Configuration

```elm
module ReviewConfig exposing (config)

import NoMissingTypeConstructor
import Review.Rule exposing (Rule)

config : List Rule
config =
    [ NoMissingTypeConstructor.rule
    ]
```


## Try it out

You can try the example configuration above out by running the following command:

```bash
elm-review --template Arkham/elm-review-no-missing-type-constructor/example
```
