module Longurl
export expand_urls

using HTTP

"""
    Urls(expanded_url, status_code)
"""
struct Urls
    expanded_url::Vector{Union{String, Nothing}}
    status_code::Vector{Union{String, Nothing}}
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

    original_stdout = stdout
    original_error = stderr

    short_urls = Vector{Union{String, Nothing}}(nothing, length(urls_to_expand))
    expanded_urls = Vector{Union{String, Nothing}}(nothing, length(urls_to_expand))
    status_codes = Vector{Union{String, Nothing}}(nothing, length(urls_to_expand))

    i = 0
    for url in urls_to_expand
        i += 1
        last_head = nothing
        last_host = nothing
        last_code = nothing
        (rd, wr) = redirect_stdout()

        try
            HTTP.head(url, readtimeout=seconds, verbose=2, retry=false)
        catch e

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
            short_urls[i] = url
            status_codes[i] = last_code
            expanded_urls[i] = last_host * last_head
        end
    end 
    
    long_urls = Urls(expanded_urls, status_codes)

    return long_urls

end

end # module
