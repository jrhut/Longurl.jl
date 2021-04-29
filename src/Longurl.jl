module Longurl
export expand_url, expand_urls

using HTTP


"""
    Url(expanded_url, status_code)
"""
struct Url
    expanded_url::Union{String, Nothing}
    status_code::Union{String, Nothing}
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

    original_stdout = stdout
    original_error = stderr

    short_url = Union{String, Nothing}
    expanded_url = Union{String, Nothing}
    status_code = Union{String, Nothing}

    last_head = nothing
    last_host = nothing
    last_code = nothing
    (rd, wr) = redirect_stdout()

    try
        HTTP.head(url_to_expand, readtimeout=seconds, verbose=2, retry=false)
    catch e
        print(e)
    finally
        redirect_stdout(original_stdout)
        close(wr)  
        for line in readlines(rd)
            if occursin("HEAD", line)
                last_head = split(line, " ")[2]
            end
            if occursin("Host", line)
                last_host = split(line, " ")[2]
            end
            if occursin("HTTP/1.1 ", line)
                last_code = split(line, " ")[2]
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