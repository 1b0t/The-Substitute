restify = require('restify')
movies = require('./movies/movies')
shows = require('./shows/shows')
seasons = require('./shows/seasons')
episodes = require('./shows/episodes')

# bootstrapping the server
server = restify.createServer()
server.use(restify.queryParser())

###
# to add basic http-header authorization un-comment this
server.pre( (req, res, next) ->
    console.log(JSON.stringify(req.headers,null,4))
    if req.headers["authorization"] == 'your secret'
        return next()
    res.status(401)
    res.end()
)
###

server.pre(restify.pre.sanitizePath())

# routes

# @param movies - array of trakt IDs or slugs
# example: /movies?movies=94024,the-breakfast-club-1985
server.get('/movies', movies.getMultiple)

# @param :trakt_id - trakt_id or slug
server.get('/movies/:trakt_id', movies.get)

# @param shows - array of trakt IDs or slugs
# example: /shows?show=60272,lost-2004
server.get('/shows', shows.getMultiple)

# @param :trakt_id - trakt_id or slug
server.get('/shows/:trakt_id', shows.get)
# example: /shows/lost-2004/seasons?seasons=1,2,3,4,5,6
server.get('/shows/:trakt_id/seasons', seasons.getMultiple)
# example: /shows/lost-2004/seasons/6
server.get('/shows/:trakt_id/seasons/:season_number', seasons.get)


# example: /shows/lost-2004/seasons/6/episodes?episodes=4,5
server.get('/shows/:trakt_id/seasons/:season_number/episodes', episodes.getMultiple)
# example: /shows/lost-2004/seasons/6/episodes/4
server.get('/shows/:trakt_id/seasons/:season_number/episodes/:episode_number', episodes.get)


server.pre(restify.pre.userAgentConnection())

server.listen(8080,'127.0.0.1', ()->
    console.log('%s listening at %s', server.name, server.url)
)
