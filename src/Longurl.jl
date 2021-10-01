module Longurl
export expand_url, expand_urls

using HTTP, SHA, Serialization, URIs


"""
    Url(expanded_url, status_code)
"""
struct Url
    expanded_url::Union{String, Nothing}
    status_code::Union{Int16, Nothing}
end

# Create unqiue filename from URL using sha256 hashing.
function url_to_cache_filename(url, cache_folder)
    key = url |> sha256|> bytes2hex
    joinpath(cache_folder, key)
end

# Make a HTTP get request, but first check the cache and if there is no hit, cache the request
function http_get_cache(url, cache_folder, seconds_expire = 60 * 60 * 24 * 60, debug = false)
    if !isdir(cache_folder) && !ispath(cache_folder)
        mkdir(cache_folder)
    end

    filename = url_to_cache_filename(url, cache_folder)
    # If the cached exsits, return it
    if isfile(filename) && seconds_expire > (time() - ctime(filename))
        debug && println("Cache Hit $(url)")
        return deserialize(filename)
    else
    # Otherwise do a HTTP request, then return and cache it.
        debug && println("Caching $(url)")
        response = HTTP.get(url, status_exception = false, retry=false, redirect = true)
        serialize(filename, response)
        return response
    end
end

# Remove a URL from the cache (for example if retrying a 4xx or 5xx request)
function http_get_cache_clear(url, cache_folder, debug = false)
    filename = url_to_cache_filename(url, cache_folder)
    if isfile(filename)
        debug && println("Deleting Cache of $(url)")
        rm(filename)
    end
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
function expand_url(url_to_expand::A, seconds::N=2, cache::String="", cache_errors::Bool=false) where {A<:String, N <: Number}
    if !startswith(url_to_expand, r"http://|https://")
        println(url_to_expand, " Invalid url no http[s]://...")
        return Url(nothing, nothing)
    end
    
    short_url = Union{String, Nothing}
    expanded_url = Union{String, Nothing}
    status_code = Union{String, Nothing}

    last_target = nothing
    last_host = nothing
    last_code = nothing

    try
        if cache != ""
            res = http_get_cache(url_to_expand, cache)
        else
            res = HTTP.get(url_to_expand, readtimeout=seconds, retry=false, redirect = true, status_exception = false, require_ssl_verification = false)
        end

        req = res.request
        last_code = res.status
        for h in req.headers
            if h[1] == "Host"
                last_host = h[2]
            end
        end
        last_target = req.target
    catch e
        if cache_errors == false
            http_get_cache_clear(url_to_expand, cache)
        end 
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

    if status_code != 200 && cache_errors == false
        http_get_cache_clear(url_to_expand, cache)
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
function expand_urls(urls_to_expand::A, seconds::N=2, cache::String="", cache_errors::Bool=false) where {A<:Vector{String}, N <: Number} 
    cache_mem = Dict()
    [cache_mem[x]=undef for x in unique(urls_to_expand)]

    results = Vector{Url}(undef, length(urls_to_expand))
    urls_to_expand = sort(urls_to_expand, by=x->URI(x).host)

    Threads.@threads for i in 1:length(urls_to_expand)
        if cache_mem[urls_to_expand[i]] == undef
            url = expand_url(urls_to_expand[i], seconds, cache, cache_errors)
            results[i] = url
            cache_mem[urls_to_expand[i]] = undef
        else
            println("Duplicate detected using cached url")
            results[i] = cache_mem[urls_to_expand[i]]
        end
        sleep(1)
    end

    return results

end

end