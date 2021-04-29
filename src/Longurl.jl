module Longurl
export expand_url, expand_urls

using HTTP


"""
    Url(expanded_url, status_code)
"""
struct Url
    expanded_url::Union{String, Nothing}
    status_code::Union{Int16, Nothing}
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
    short_url = Union{String, Nothing}
    expanded_url = Union{String, Nothing}
    status_code = Union{String, Nothing}

    last_target = nothing
    last_host = nothing
    last_code = nothing

    try
        res = HTTP.get(url_to_expand, readtimeout=seconds, retry=false, redirect = true, status_exception = false)
        req = res.request
        last_code = res.status
        for h in req.headers
            if h[1] == "Host"
                last_host = h[2]
            end
        end
        last_target = req.target
    catch e
        println(e)
    finally
        short_urls = url_to_expand
        status_code = last_code
        if last_host != nothing || last_target != nothing
            expanded_url = last_host * last_target
        else
            expanded_url = nothing
        end
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
    urls_to_expand = unique!(urls_to_expand)

    results = Vector{Url}(undef, length(urls_to_expand))

    Threads.@threads for i in 1:length(urls_to_expand)
        results[i] = expand_url(urls_to_expand[i])
    end

    return results

end

end