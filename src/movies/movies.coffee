mediaFetchRequest = require('../common/mediaFetchRequest')

self = module.exports =

    get : (req, res, next) ->
        mediaFetchRequest.get(req,res,next, mediaFetchRequest.mediaType.Movies)
        return

    getMultiple : (req, res, next) ->
        mediaFetchRequest.getMultiple(req,res,next, mediaFetchRequest.mediaType.Movies)
        return