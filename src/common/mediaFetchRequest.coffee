https = require('https')
utils = require('../utils/utils')
cache = require('../utils/cache')
trakt = require('../external-services/trakt')
fanarttv = require('../external-services/fanarttv')
tmdb = require('../external-services/tmdb')
config = require('../config.json')

# TODO: refactor
self = module.exports =
    mediaType:
        Movies : "movies"
        Shows : "shows"

    # contract: returns json
    fetchImageDataForTraktID : (trakt_id,mediaType,callback,season_number = null,episode_number = null) ->
        
        traktIDs = null
        pendingRequests = 0
        result = {}

        success = (json) ->
            result.reference_id = trakt_id # slug or id depending on the request
            result.ids = traktIDs
            result.success = true
            
            if json.service == "tmdb"
                result.tmdb = json
            if json.service == "fanarttv"
                result.fanarttv = json

            finalize()

        error = (err,genericMessage) ->
            result.errors = []

            if err?
                err.reference_id = trakt_id
                result.errors.push(err)
            else
                genericMessage.reference_id = trakt_id
                result.errors.push(genericMessage)
            finalize()


        finalize = () ->
            pendingRequests = pendingRequests - 1
            if pendingRequests <= 0
                if season_number?
                    result.season = season_number
                if episode_number?
                    result.episode = episode_number
                result.reference_id = trakt_id
                if config.merge_assets? && config.merge_assets == true
                    utils.merge(result)
                    
                callback(result)


        processResponseFromTrakt = (json,err) ->
            if json?
                pendingRequests = pendingRequests - 1
                traktIDs = json["ids"]
                console.log(JSON.stringify(traktIDs,null,4))
                if traktIDs?
                    if config.tmdb.enabled
                        id = json["ids"]["tmdb"]
                        if id?
                            pendingRequests = pendingRequests + 1
                            switch mediaType
                                when self.mediaType.Movies
                                    tmdb.fetchImageMetaData(
                                        tmdb.mediaType.Movie,
                                        id,
                                        processResponseFromTMDB)
                                when self.mediaType.Shows
                                    tmdb.fetchImageMetaData(
                                        tmdb.mediaType.Show,
                                        id,
                                        processResponseFromTMDB,season_number,episode_number)
                    if config.fanarttv.enabled
                        pendingRequests = pendingRequests + 1
                        switch mediaType
                            when self.mediaType.Movies
                                id = json["ids"]["imdb"]
                                if id?
                                    fanarttv.fetchImageMetaData(
                                        fanarttv.mediaType.Movie,
                                        id,
                                        processResponseFromFanartTV)
                            when self.mediaType.Shows
                                id = json["ids"]["tvdb"]
                                if id?
                                    fanarttv.fetchImageMetaData(
                                        fanarttv.mediaType.Show,
                                        id,
                                        processResponseFromFanartTV,season_number,episode_number)
                    if config.fanarttv.enabled == false && config.tmdb.enabled == false
                        error(null,{success:false,message:"no third party image services enabled in config.json"})
                            
                else
                    error(null, {success:false,service:"trakt",message:"failed to get ids from trakt"})
            else
                error(err, {success:false,service:"trakt",message:"failed to load data from trakt"})

        processResponseFromFanartTV = (json, err) ->
            if json?
                success(json)
            else
                error(err, {success:false,service:"fanarttv",message:"failed to load data from fanarttv"})

        processResponseFromTMDB = (json, err) ->
            if json?
                success(json)
            else
                error(err,{success:false,service:"tmdb",message:"failed to load data from tmdb"})

        pendingRequests = pendingRequests + 1
        switch mediaType
            when self.mediaType.Movies
                trakt.fetchIDs(trakt.mediaType.Movie, trakt_id, processResponseFromTrakt)
            when self.mediaType.Shows
                trakt.fetchIDs(trakt.mediaType.Show, trakt_id, processResponseFromTrakt)
            else
                error(null,{status:false,message:"mediaType not supported"})
                

    get : (req, res,next, mediaType) ->

        trakt_id = req.params.trakt_id
        season_number = req.params.season_number
        episode_number = req.params.episode_number

        if trakt_id?
            self.fetchImageDataForTraktID(trakt_id,mediaType, (json)->
                res.send(json)
                next()
            , season_number, episode_number)
        else
            res.send({success:false,message:"required parameter :trakt_id missing"})
            next()
        return
    
    getMultiple : (req, res,next, mediaType) ->

        # returns json array
        fetchImageDataForTraktIDs = (ids,callback) ->

            pendingRequests = ids.length
            result = []
            
            fetchedDataForMedia = (json) ->
                pendingRequests -= 1
                result.push(json)

                if pendingRequests == 0
                    cache.save(req.params[mediaType],JSON.stringify(result))
                    callback(result)

            for id in traktIDs
                self.fetchImageDataForTraktID(id, mediaType, fetchedDataForMedia)
            
        if req.params[mediaType]?
            traktIDs = req.params[mediaType].split(',')
            if traktIDs.length > 0 && req.params[mediaType].length > 0

                cache.load("?movies=" + req.params[mediaType], (cachedData) ->
                    if cachedData?
                        json = JSON.parse(cachedData)
                        if json?
                            res.send(json)
                            next()
                            return
                    # no cache hit -> fetch
                    fetchImageDataForTraktIDs(traktIDs, (json)->
                        res.send({success:true,data:json})
                        next()
                        )
                )
            
            else
                res.status(400)
                res.send({
                    success: false,
                    message: "comma seperated list of movie_ids or slugs named 'movies' is required"}
                )
                next()
        else
            res.status(400)
            res.send({success:false})
            next()