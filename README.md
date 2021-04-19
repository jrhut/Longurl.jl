# longurl.jl
 A Julia implementation of the R package longurl. For transforming short url's back into their long form. 
 
## Installation

Clone this repository to your local system

Install depencies with

```
using Pkg
Pkg.add("DataFrames")
Pkg.add("HTTP")
```

Now all thats left to use this project is starting up the project environment with Pkg.activate("path/to/Longurl.jl")

This allows you to use ```using Longurl```

## Usage

This package provides function expand_urls that will take an array of short urls and return a dataframe with the original url, expanded url and status code. 

```
  expand_urls(urls_to_expand)
  
Takes a list of short urls and exands them into their long form

...
# Arguments
- `urls_to_expand::Array`: the list of short urls
- `seconds::Int64`: the timeout in seconds, default=2
# Returns
- `DataFrame`: DataFrame containing the short url, expanded url and status code
...
```

## Examples

```
expand_urls(["https://tinyurl.com/yfr3dtha"])

...

 Row │ orig_url                      expanded_url     status_code
     │ String                        String           String          
─────┼─────────────────────────────────────────────────────────────
   1 │ https://tinyurl.com/yfr3dtha  www.google.com/  200

```
