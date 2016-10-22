https = require('https')
utils = require('../utils/utils')
cache = require('../utils/cache')
keys = require('./keys.json')
config = require('../config.json').tmdb

self = module.exports =
    mediaType :
        Movie : "movie"
        Show : "tv"
    fetchImageMetaData : (mediaType,tvdb_id,callback,season_number = null,episode_number = null) ->
        
        # first we need to get the configuration construct the urls
        TMDB_BASE_URL = "api.themoviedb.org"
        TMDB_API_VERSION = "3"

        fetchConfiguration = (callback) ->
            options =
                host: TMDB_BASE_URL,
                path: "/" + TMDB_API_VERSION + "/configuration?api_key=" + keys.TMDB_API_KEY
                headers:
                    "Content-Type" : "application/json"

            url = utils.buildURLwithOptions(options)

            tmdbConfigurationCallback = (response) ->
                data = ''

                response.on('data', (chunk) ->
                    data += chunk
                )

                response.on('end', () ->

                    if response.statusCode == 200
                        json = JSON.parse(data)
                        if json?
                            cache.save(url,JSON.stringify(json),86400)
                            fetchImageMetaData(callback,json)
                        else
                            callback(null, {
                                success:false,
                                service:"tmdb",
                                message:"[TMDB#configuration] empty response; could not parse json"})
                    else
                        callback(null, {success:false,service:"tmdb",message:"[TMDB#request-failed] " + url})
            )

            cache.load(url, (cachedData) ->
                if cachedData?
                    json = JSON.parse(cachedData)
                    if json?
                        fetchImageMetaData(callback,json)
                        return
                else
                    console.info("[TMDB] " + url)
                    https.request(options, tmdbConfigurationCallback).end()
            )

        processData = (json,configuration) ->

            relevantInfo = {}

            if configuration["images"]? && configuration["images"]["secure_base_url"]?
                baseURL = configuration["images"]["secure_base_url"]
                for key, alias of config.asset_mapping
                    if json[key]? && json[key][0]? && json[key][0]["file_path"]?
                        if key.slice(0,-1)? && configuration["images"][key.slice(0,-1) + "_sizes"]?
                            relevantInfo[alias] = {}
                            for size in configuration["images"][key.slice(0,-1) + "_sizes"]
                                relevantInfo[alias][size] = baseURL + [size] + json[key][0]["file_path"]
                        else
                            relevantInfo[alias] = {original:baseURL + "original" + json[key][0]["file_path"]}
                    else
                        relevantInfo[alias] = null
            relevantInfo.service = "tmdb"
            return relevantInfo
        
        fetchImageMetaData = (callback,configuration) ->
            options =
                host: TMDB_BASE_URL,
                path: "/" + TMDB_API_VERSION + "/" + mediaType + "/" + tvdb_id + "/images?api_key=" + keys.TMDB_API_KEY
                headers:
                    "Content-Type" : "application/json"
            if season_number?
                options.path =  "/" + TMDB_API_VERSION + "/tv/" + tvdb_id +
                    "/season/" + season_number + "/images?api_key=" + keys.TMDB_API_KEY
            if season_number? && episode_number?
                options.path =  "/" + TMDB_API_VERSION + "/tv/" + tvdb_id +
                    "/season/" + season_number + "/episode/" + episode_number + "/images?api_key=" + keys.TMDB_API_KEY
                console.log(options.path)

            url = utils.buildURLwithOptions(options)

            tmdbRequestCallback = (response) ->
                data = ''

                response.on('data', (chunk) ->
                    data += chunk
                )

                response.on('end', () ->

                    if response.statusCode == 200
                        json = JSON.parse(data)
                        if json?
                            info = processData(json,configuration)
                            cache.save(url,JSON.stringify(info))
                            callback(info,null)
                        else
                            callback(null,{success:false,service:"tmdb",message:"empty response; could not parse json"})
                    else
                        callback(null, {success:false,service:"tmdb",message:"[TMDB#request-failed] " + url})
            )

            cache.load(url, (cachedData) ->
                if cachedData?
                    json = JSON.parse(cachedData)
                    if json?
                        callback(json,null)
                        return
                https.request(options, tmdbRequestCallback).end()
            )

        fetchConfiguration(callback)
        return

