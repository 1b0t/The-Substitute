redis = require('redis')
config = require('../config.json')
client = redis.createClient()

client.on("error",  (error) ->
    # TODO: improve error handling; return 500 if redis is not running.
    console.log("Error " + error)
)

module.exports =
    
    save : (url, data,expire = config.cache_expires_after_seconds) ->
        client.set(url, data, redis.print)
        client.expire(url, expire)
        return

    load : (url, callback) ->
        client.get(url,  (err, data) ->
            if data?
                callback(data)
            else
                callback(null)
            if err?
                callback(null)
        )
        return