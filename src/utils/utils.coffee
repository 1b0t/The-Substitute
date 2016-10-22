config = require('../config.json')

module.exports =

    buildURLwithOptions : (options) ->
        options.host + options.path


    merge : (result) ->
        if config.merge_assets? && config.merge_assets == true
            result["images"] = {}

            # merge with default priorities
            if config.merge_priority_defaults?
                for service in config.merge_priority_defaults
                    if result[service]?
                        for assetName, assets of result[service]
                            if assetName != "service" # TODO
                                result["images"][assetName] = assets
            # cherry pick
            for assetName, priorities of config.merge_prioritys
                for service in priorities
                    if result[service]? && result[service][assetName]?
                        result["images"][assetName] = result[service][assetName]
                        break
        if config.merge_priority_defaults?
            for service in config.merge_priority_defaults
                delete result[service]