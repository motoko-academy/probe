let Package = { name : Text, version : Text, repo : Text, dependencies : List Text }
in  [
    { name = "base"
    , repo = "https://github.com/dfinity/motoko-base"
    , version = "a827ab2399aa2b0c902976a16edbac569d330049"
    , dependencies = [] : List Text
    }
] : List Package
