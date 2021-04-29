module Longurl
export expand_url, expand_urls

using HTTP


"""
    Url(expanded_url, status_code)
"""

struct Urls
    expanded_url::Vector{Union{String, Nothing}}
    status_code::Vector{Union{Int64, Nothing}}
end


"""
Takes a short url and expands it into their long form

...
# Arguments
- `url_to_expand::String`: the short url
- `seconds::Int64`: the timeout in seconds
# Returns
- `Url`: Struct containing properties expanded_url and status_code
...
"""
function expand_url(url_to_expand::A, seconds::N=2) where {A<:String, N <: Number} 

    short_url = Vector{Union{String, Nothing}}(nothing, length(urls_to_expand))
    expanded_url = Vector{Union{String, Nothing}}(nothing, length(urls_to_expand))
    status_code = Vector{Union{Int64, Nothing}}(nothing, length(urls_to_expand))

    i = 0
    for url in urls_to_expand
        i += 1
        last_target = nothing
        last_host = nothing
        last_code = nothing

        try
            res = HTTP.get(url, readtimeout=seconds, retry=false, redirect = true, status_exception = false, verbose = 2)
            req = res.request
            last_code = res.status
            print(last_code)
            for h in req.headers
                if h[1] == "Host"
                    last_host = h[2]
                end
            end
            last_target = req.target
               
        catch e
            print(e)
        finally
            short_urls[i] = url
            status_codes[i] = last_code
            if last_host != nothing || last_target != nothing
                expanded_urls[i] = last_host * last_target
            else
                expanded_urls[i] = nothing
            end
        end
        short_url = url_to_expand
        status_code = last_code
        expanded_url = last_host * last_head
    end
    
    long_url = Url(expanded_url, status_code)

    return long_url
end


"""
Takes a vector of short urls and expands them into their long form

...
# Arguments
- `urls_to_expand::Vector{String}`: the short urls
- `seconds::Int64`: the timeout in seconds
# Returns
- `Url`: Struct containing properties expanded_url and status_code
...
"""
function expand_urls(urls_to_expand::A, seconds::N=2) where {A<:Vector{String}, N <: Number} 
    return expand_url.(urls_to_expand)
end

end
