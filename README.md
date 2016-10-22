# The Substitute

The server can provide images assets for given `trakt.tv` IDs. Ihe project aims to provide easy access to the once called `poster`, `fanart`, `screenshot`,`banner`,`logo` and `clearart` assets.

The main goal of this project is to help with [this: Trakt.tv API Images will be removed on October 31, 2016.](https://apiblog.trakt.tv/trakt-api-images-56b43c356427)

ℹ️️️️️ You are welcome to contribute to this project.

⚠️ Be sure to optain the proper API keys depending on your needs. This should be obvious: You are responsible to check if the usage of this app complies with the terms and conditions of third parties for which you plug-in API keys.

### Progress Overview
| feature                   | Movies     | TV Shows  |Seasons    | Episodes  |
| ------------------------- |:----------:|:---------:|:---------:|:---------:|
| cherry pick via `config`  | ✅           |✅          |✅          |✅           |
| single                    | ✅          |✅          |✅          |✅           |
| batch request             | ✅          |✅          |✅          |✅           |
| TMDb                      | ✅          |✅          |✅          |✅           |
| fanart.tv                 | ✅          |✅         |❌         |N/A         |

##### Known limitations

- The app can't figure out how many seaons are in a show / how many episodes in a season. However, this should not really be an issue since you probably have this data available prior to making the image requests anyway.

### Scope
#### Goals
- Meta-data aggregation for image assets from different sources like TMDb and fanart.tv.
- Easily mix and match data from preferred sources via `config.json` file.
- Provide a clean API; Constructible urls based on `trakt.tv` ID.

#### Non-Goals
- being a caching proxy
- downloading, caching and resizing of images

## Setup

⚠️ Be sure to optain the proper API keys depending on your needs.

Create `dist/external-services/keys.json` with the following content:

        ```json
        {
            "TRAKT_CLIENT_ID" : "",
            "FANART_TV_API_KEY" : "",
            "TMDB_API_KEY" : ""
        }
        ```

[Redis](http://redis.io) is required. If you want to use some other kv-store it should be pretty straight forward to adjust `src/utils/cache.coffee` to your needs.

## Configuration

You can adjust this to your preferences by modifying `dist/config.json`:
        
        ```coffee
        {
            "cache_expires_after_seconds": 86400,
            "merge_assets" : false,

            # these will be used if no explicit priorities are set in merge_prioritys 
            "merge_priority_defaults" : ["tmdb","fanarttv"],

            # set explicit merge priorities for certain assets based on assets_mapping
            "merge_prioritys" :{
                "poster":["tmdb","fanarttv"],
                "fanart":["tmdb","fanarttv"]
            },
            "tmdb":{
                "enabled" : true,

                # map these to your preference
                "asset_mapping" : {
                        "posters" : "poster",
                        "backdrops" : "fanart",
                        "stills" : "screenshot"
                    }
            },
            "fanarttv" :{
                "enabled" : true,
                "asset_mapping" : {
                    "movies":{
                        "moviebackground":"fanart",
                        "movieposter":"poster",
                        "moviedisc":null,
                        "moviebanner":"banner",
                        "hdmovieclearart":"clearart",
                        "movielogo":null,
                        "hdmovielogo":"logo"
                    },
                    "tv":{
                        "showbackground":"fanart",
                        "tvposter":"poster",
                        "tvbanner":"banner",
                        "clearart":"clearart",
                        "hdtvlogo":"logo",
                        "clearlogo":null
                    }
                }
            }
        }
        ```

## Usage

    # @param movies - array of trakt IDs or slugs
    # example: /movies?movies=94024,the-breakfast-club-1985
    GET /movies

    # @param :trakt_id - trakt_id or slug
    GET /movies/:trakt_id

    # @param shows - array of trakt IDs or slugs
    # example: /shows?show=60272,lost-2004
    GET /shows

    # @param :trakt_id - trakt_id or slug
    GET /shows/:trakt_id

    # example: /shows/lost-2004/seasons?seasons=1,2,3,4,5,6
    GET /shows/:trakt_id/seasons

    # example: /shows/lost-2004/seasons/6
    GET /shows/:trakt_id/seasons/:season_number

    # example: /shows/lost-2004/seasons/6/episodes?episodes=4,5
    GET /shows/:trakt_id/seasons/:season_number/episodes
    
    # example: /shows/lost-2004/seasons/6/episodes/4
    GET /shows/:trakt_id/seasons/:season_number/episodes/:episode_number

### Example Responses

    /movies/the-breakfast-club-1985

#### merge_assets disabled 

    ```json
    {
        "reference_id": "the-breakfast-club-1985",
        "ids": {
            "trakt": 1457,
            "slug": "the-breakfast-club-1985",
            "imdb": "tt0088847",
            "tmdb": 2108
        },
        "success": true,
        "tmdb": {
            "poster": {
                "w92": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg",
                "w154": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg",
                "w185": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg",
                "w342": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg",
                "w500": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg",
                "w780": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg",
                "original": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg"
            },
            "fanart": {
                "w300": "https://image.tmdb.org/t/p/original/tUSXZ37j0XpNtmOb5uwqogdcq7E.jpg",
                "w780": "https://image.tmdb.org/t/p/original/tUSXZ37j0XpNtmOb5uwqogdcq7E.jpg",
                "w1280": "https://image.tmdb.org/t/p/original/tUSXZ37j0XpNtmOb5uwqogdcq7E.jpg",
                "original": "https://image.tmdb.org/t/p/original/tUSXZ37j0XpNtmOb5uwqogdcq7E.jpg"
            },
            "service": "tmdb"
        },
        "fanarttv": {
            "fanart": null,
            "poster": {
                "original": "http://assets.fanart.tv/fanart/movies/2108/movieposter/the-breakfast-club-55d8a90d6863d.jpg"
            },
            "banner": {
                "original": "http://assets.fanart.tv/fanart/movies/2108/moviebanner/the-breakfast-club-544e7fb3029cf.jpg"
            },
            "clearart": {
                "original": "http://assets.fanart.tv/fanart/movies/2108/hdmovieclearart/the-breakfast-club-55b44756c9af3.png"
            },
            "logo": {
                "original": "http://assets.fanart.tv/fanart/movies/2108/hdmovielogo/the-breakfast-club-51628a565578b.png"
            },
            "service": "fanarttv"
        }
    }
    ```

#### merge_assets enabled 

    ```json
    {
        "reference_id": "the-breakfast-club-1985",
        "ids": {
            "trakt": 1457,
            "slug": "the-breakfast-club-1985",
            "imdb": "tt0088847",
            "tmdb": 2108
        },
        "success": true,
        "images": {
            "poster": {
                "w92": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg",
                "w154": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg",
                "w185": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg",
                "w342": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg",
                "w500": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg",
                "w780": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg",
                "original": "https://image.tmdb.org/t/p/original/4ZejrrCpfoypR5lHoT3pq6yVldW.jpg"
            },
            "fanart": {
                "w300": "https://image.tmdb.org/t/p/original/tUSXZ37j0XpNtmOb5uwqogdcq7E.jpg",
                "w780": "https://image.tmdb.org/t/p/original/tUSXZ37j0XpNtmOb5uwqogdcq7E.jpg",
                "w1280": "https://image.tmdb.org/t/p/original/tUSXZ37j0XpNtmOb5uwqogdcq7E.jpg",
                "original": "https://image.tmdb.org/t/p/original/tUSXZ37j0XpNtmOb5uwqogdcq7E.jpg"
            },
            "banner": {
                "original": "http://assets.fanart.tv/fanart/movies/2108/moviebanner/the-breakfast-club-544e7fb3029cf.jpg"
            },
            "clearart": {
                "original": "http://assets.fanart.tv/fanart/movies/2108/hdmovieclearart/the-breakfast-club-55b44756c9af3.png"
            },
            "logo": {
                "original": "http://assets.fanart.tv/fanart/movies/2108/hdmovielogo/the-breakfast-club-51628a565578b.png"
            }
        }
    }
    ```

## Deployment

tl;dr Don't deploy this without implementing the things listed under highly recommended.

Written in `coffee` trakt image server is build on top of `nodejs` and `redis`.

#### Prerequisits

* node running on your server
* rediis running on your server

#### (Highly) Recommended

* add nginx and your SSL certificates
* add some kind of caching layer
* use [pm2](http://pm2.keymetrics.io) or something similar for easy deployment & clustering
* add some kind of access control so that your server doesn't get abused

It should be pretty straight forward to adjust other settings to your needs.

### License

The MIT License (MIT)
Copyright (c) 2016 Tobias Arends

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.