# Setup

1. Install [cocoapods](http://cocoapods.org)
2. `pod install`

# A Note on Formats

## `ingredients.json`

Ingredients must have a human-readable `display` field, which is presented to the user whe picking through ingredients.

Additionally, ingredients may have the following attributes:

- `tag`: The unique tag that identifies this ingredient when its referred to in recipes. If absent, the lowercased version of the display string is used.
- `generic`: Which generic ingredient best represents this ingredient, if any. Used for fuzzy matching and substitutions.
- `hidden`: Set to true if this ingredient should not appear in the ingredient list. This is a kludge so that uselessly vague ingredients (e.g. "rum" when we'd like to really specify white/dark/spiced) or nonsensical generics (e.g. "chartreuse" to capture yellow and green, even though there's not really a standalone "chartreuse") don't crop up in the selection view. In the future, hopefully their existence can be inferred and these ingredients will simply not be present in the JSON at all.
