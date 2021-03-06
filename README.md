# hubot-recurry 

Interface to recurry, the [recurring REST-call scheduler](https://www.npmjs.com/package/recurry)

# Installation 

    npm install hubot-recurry

# Usage:

    hubot recurry                           - get overview of scheduled jobs (being pushed to core)
    hubot recurry add                       - how to add a recurring scheduled call
    hubot recurry remove <id>               - stop and remove a scheduler
    hubot recurry reset <id>                - reset 'triggered' field to zero
    hubot recurry scheduler <action> <id>   - control a scheduler, actions: start, stop, resume, pause
    hubot recurry setpayload <id> <jsonstr> - set json payload for scheduled call
    hubot recurry setscheduler              - set scheduler frequency
    hubot recurry view <id>                 - view details and payload of scheduled call
    hubot recurry trigger <id>              - manually trigger scheduler, regardless of scheduletime

# Environment vars

    RECURRY_URL               <- your recurry url (so hubot can post to that)

# Testing 

    $ npm install recurry  # one time
    $ RECURRY_PATH=$(pwd)/node_modules/node-recurry ./test/commands
