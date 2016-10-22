https = require('https')
utils = require('../utils/utils')
cache = require('../utils/cache')
keys = require('./keys.json')
config = require('../config.json').fanarttv

module.exports =
    mediaType :
        Movie : "movies"
        Show : "tv"
    fetchImageMetaData : (mediaType,imdb_id,callback,season_number = null,episode_number = null) ->

        if episode_number? || season_number?
            callback(null, {service:"fanarttv",status:501,message:"not implemented"})
            return

        processData = (json) ->
  
            relevantInfo = {}

            for key, alias of config.asset_mapping[mediaType]
                if alias?
                    if json[key]? && json[key][0]? && json[key][0]["url"]
                        relevantInfo[alias] = {original : json[key][0]["url"]}
                    else
                        relevantInfo[alias] = null
           
            relevantInfo.service = "fanarttv"
            relevantInfo

        # first we need ids from trakt
        options =
            host: 'webservice.fanart.tv',
            path: "/v3/" + mediaType + "/" + imdb_id + "?api_key=" + keys.FANART_TV_API_KEY
            headers:
                "Content-Type" : "application/json"
                
        url = utils.buildURLwithOptions(options)

        fanarttvRequestCallback = (response) ->
            data = ''

            response.on('data', (chunk) ->
                data += chunk
            )

            response.on('end', () ->
                if response.statusCode == 200
                    json = JSON.parse(data)
                    if json?
                        info = processData(json)

                        cache.save(url,JSON.stringify(info))
                        callback(info,null)
                    else
                        callback(null,{service:"fanarttv",message:"[fanarttv]empty response; could not parse json"})
                else
                    callback(null, {service:"fanarttv",message:"[fanarttv#request-failed] " + url})
        )

        cache.load(url, (cachedData) ->
            if cachedData?
                json = JSON.parse(cachedData)
                if json?
                    callback(json,null)
                    return
            https.request(options, fanarttvRequestCallback).end()
        )
        return