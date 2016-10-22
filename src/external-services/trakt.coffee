https = require('https')
utils = require('../utils/utils')
cache = require('../utils/cache')
keys = require('./keys.json')
config = require('../config.json')

module.exports =
    mediaType :
        Movie : "movies"
        Show : "shows"
    fetchIDs : (mediaType,trakt_id_or_slug,callback) ->
        
      # first we need ids from trakt
        options =
            host: 'api.trakt.tv',
            path: "/" + mediaType + "/" + trakt_id_or_slug
            headers:
                "Content-Type" : "application/json"
                "trakt-api-version" : 2,
                "trakt-api-key" : keys.TRAKT_CLIENT_ID

        url = utils.buildURLwithOptions(options)

        traktRequestCallback = (response) ->
            data = ''

            response.on('data', (chunk) ->
                data += chunk
            )

            response.on('end', () ->
                if response.statusCode == 200
                    json = JSON.parse(data)
                    if json?
                        cache.save(url,data)
                        #console.log JSON.stringify(json,null,4)
                        callback(json,null)
                    else
                        callback(null,
                            {success:false,message:"empty response; could not parse json"}
                            )
                else
                    callback(null, {success:false,message:"[trakt#request-failed] " + url})
            )

        cache.load(url, (cachedData) ->
            if cachedData?
                json = JSON.parse(cachedData)
                if json?
                    callback(json,null)
                    return
            https.request(options, traktRequestCallback).end()
        )
        return