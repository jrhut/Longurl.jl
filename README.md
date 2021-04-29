# Longurl.jl
 A Julia implementation of the R package longurl. For transforming short url's back into their long form. 
 
## Installation

Install the package using ```Pkg.add(url="https://github.com/jrhut/Longurl.jl")```

This allows you to use ```using Longurl```

## Usage

This package provides function expand_urls that will take an array of short urls and return a dataframe with the original url, expanded url and status code. If the request itself fails expanded_url and status_code will equal 'missing'. 

```
  expand_urls(urls_to_expand)
  
Takes a list of short urls and exands them into their long form

...
# Arguments
- `urls_to_expand::Array`: the list of short urls
- `seconds::Int64`: the timeout in seconds
# Returns
- `Urls`: Struct containing properties expanded_url and status_code
...
```

```
 expand_url(url_to_expand)

Takes a short url and expands it into their long form

...
# Arguments
- `url_to_expand::String`: the short url
- `seconds::Int64`: the timeout in seconds
# Returns
- `Url`: Struct containing properties expanded_url and status_code
...
```

## Examples

```
expand_url("https://tinyurl.com/yfr3dtha")

expand_urls(["https://tinyurl.com/yfr3dtha"])
```
