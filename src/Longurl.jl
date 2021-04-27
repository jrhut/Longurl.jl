module Longurl
export expand_urls

using HTTP

"""
    Urls(expanded_url, status_code)
"""
struct Urls
    expanded_url::Vector{Union{String, Nothing}}
    status_code::Vector{Union{Int64, Nothing}}
end

"""
Takes a list of short urls and exands them into their long form

...
# Arguments
- `urls_to_expand::Array`: the list of short urls
- `seconds::Int64`: the timeout in seconds
# Returns
- `Urls`: Struct containing properties expanded_url and status_code
...
"""
function expand_urls(urls_to_expand::A, seconds::N=2) where {A<:Union{String,Vector{String}}, N <: Number} 

    short_urls = Vector{Union{String, Nothing}}(nothing, length(urls_to_expand))
    expanded_urls = Vector{Union{String, Nothing}}(nothing, length(urls_to_expand))
    status_codes = Vector{Union{Int64, Nothing}}(nothing, length(urls_to_expand))

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
    end 
    
    long_urls = Urls(expanded_urls, status_codes)

    return long_urls

end

end # module


