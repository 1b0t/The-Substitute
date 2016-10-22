mediaFetchRequest = require('../common/mediaFetchRequest')
utils = require('../utils/utils')
cache = require('../utils/cache')

self = module.exports =

    get : (req, res, next) ->
        mediaFetchRequest.get(req,res,next, mediaFetchRequest.mediaType.Shows)
        return

    getMultiple : (req, res,next) ->
        console.log("test")
        mediaType = "episodes"
        season_number = req.params.season_number
        trakt_id = req.params.trakt_id

        if trakt_id? && season_number?
            # returns json array
            fetchImageDataForEpisodeIDs = (ids,callback) ->

                pendingRequests = ids.length
                result = []
                
                fetchedDataForMedia = (json) ->
                    pendingRequests -= 1
                    result.push(json)

                    if pendingRequests == 0
                        cache.save(req.params[mediaType],JSON.stringify(result))
                        callback(result)

                for id in episodeIDs
                    mediaFetchRequest.fetchImageDataForTraktID(
                        trakt_id,
                        mediaFetchRequest.mediaType.Shows,
                        fetchedDataForMedia,season_number,id)
                
            if req.params[mediaType]?
                episodeIDs = req.params[mediaType].split(',')
                if episodeIDs.length > 0 && req.params[mediaType].length > 0

                    cache.load("/show/" + trakt_id+ "/seasons/" + season_number+ "/episodes?episodes="+ req.params[mediaType], (cachedData) ->
                        if cachedData?
                            json = JSON.parse(cachedData)
                            if json?
                                res.send(json)
                                next()
                                return
                        # no cache hit -> fetch
                        fetchImageDataForEpisodeIDs(episodeIDs, (json)->
                            res.send({success:true,data:json})
                            next()
                            )
                    )
                
                else
                    res.status(400)
                    res.send({
                        success: false,
                        message: "comma seperated list of seaons_ids or slugs named 'movies' is required"}
                    )
                    next()
            else
                res.status(400)
                res.send({success:false})
                next()
        else # end trakt_id?
            res.send({success:false,message:"required parameter :trakt_id missing"})
            next()
        return

        