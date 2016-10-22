mediaFetchRequest = require('../common/mediaFetchRequest')

self = module.exports =

    get : (req, res, next) ->
        mediaFetchRequest.get(req,res,next, mediaFetchRequest.mediaType.Shows)
        return

    getMultiple : (req, res, next) ->
        mediaFetchRequest.getMultiple(req,res,next, mediaFetchRequest.mediaType.Shows)
        return