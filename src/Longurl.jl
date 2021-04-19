module Longurl
export expand_urls

using HTTP
using DataFrames

"""
Takes a list of short urls and exands them into their long form

...
# Arguments
- `urls_to_expand::Array`: the list of short urls
- `seconds::Int64`: the timeout in seconds
# Returns
- `DataFrame`: DataFrame containing the short url, expanded url and status code
...
"""
function expand_urls(urls_to_expand, seconds=2)

    original_stdout = stdout
    original_error = stderr

    short_urls = []
    expanded_urls = []
    status_codes = []

    for url in urls_to_expand
        last_head = missing
        last_host = missing
        last_code = missing
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
            append!(short_urls, [url])
            append!(status_codes, [last_code])
            append!(expanded_urls, [last_host * last_head])
        end
    end 
    
    df = DataFrame(short_urls=short_urls, long_urls=expanded_urls, status_codes=status_codes)

    return df

end

end # module
