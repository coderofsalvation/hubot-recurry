# Description:
#   interface to recurry 
#
# Dependencies: easy-table
#
# Commands:
#   hubot recurry                           - get overview of scheduled jobs (being pushed to core)
#   hubot recurry setscheduler              - set scheduler frequency
#   hubot recurry setpayload <id> <jsonstr> - set json payload for scheduled call 
#   hubot recurry view <id>                 - view details and payload of scheduled call 
#   hubot recurry add                       - how to add a recurring scheduled call 
#   hubot recurry scheduler <action> <id>   - control a scheduler, actions: start, stop, resume, pause 
#   hubot recurry reset <id>                - reset 'triggered' field to zero 
#   hubot recurry remove <id>               - stop and remove a scheduler 
#
# Author:
#   Leon van Kammen
#

module.exports = (robot) ->
  util      = require('util')
  ascii     = require('easy-table')

  recurry = 
    url: ( if process.env.RECURRY_URL then process.env.RECURRY_URL else "http://localhost:3333")
    usage:
      setscheduler: "Usage: recurry setscheduler <id> <phrase>\n\n
Example: recurry setscheduler 12 every 5 mins\n\nphrases: \n
\t314 milliseconds\n
\t5 minutes 15 seconds\n
\tan hour and a minute\n
\t1 Hour, 5 Minutes And 15 Seconds\n
\t2h 15m 15s\n
\t3 weeks, 5 days, 6 hours\n
\t3 weeks, 5d 6h"
      add: "Usage: recurry add <method> <url> <name>\n\n
Example: recurry add get http://fooo.com get_foo_com\n
         recurry setpayload get_foo_com {\"foo\":\"bar\"}\n"

  format = (data,format) ->
    if format is "ascii"
      a = new ascii
      for row in data
        for key,value of row 
          value = '{}' if typeof value is 'object'
          a.cell( key, value ) 
        a.newRow()
      return a.toString()

  robot.respond /recurry$/i, (msg) ->
    robot.http( recurry.url+"/scheduler"  ).get() (err,res,body) ->
      data = JSON.parse(body)
      msg.send format(data,'ascii')
  
  robot.respond /recurry reset (.*)/i, (msg) ->
    args = msg.match[1].split(" ")
    return msg.send("Usage: recurry reset <id>") if args.length != 1
    robot.http( recurry.url+"/scheduler/reset/"+args[0]  ).get() (err,res,body) ->
      data = JSON.parse(body)
      msg.send format(data,'ascii')
  
  robot.respond /recurry add$/i, (msg) ->
    msg.send( recurry.usage.add )

  robot.respond /recurry add (.*)/i, (msg) ->
    args = msg.match[1].split(" ")
    return msg.send( recurry.usage.add ) if args.length != 3
    data = {}
    data.id     = args.pop()
    data.url    = args.pop()
    data.method = args.pop()
    data.scheduler = "?"
    console.dir data
    robot.http( recurry.url+"/scheduler"  )
      .header('Content-Type', 'application/json')
      .post( JSON.stringify(data) ) (err,res,body) ->
        console.dir body
        data = JSON.parse(body)
        msg.send "OK" if typeof JSON.stringify(data) is 'object'

  robot.respond /recurry setscheduler$/i, (msg) ->
    msg.send( recurry.usage.setscheduler )
  
  robot.respond /recurry remove (.*)/i, (msg) ->
    args = msg.match[1].split(" ")
    return msg.send(recurry.usage.setscheduler) if args.length < 1
    id = args.shift()
    robot.http( recurry.url+"/scheduler/remove/"+id  )
      .header('Content-Type', 'application/json')
      .get() (err,res,body) ->
        msg.send body 

  robot.respond /recurry setscheduler (.*)/i, (msg) ->
    args = msg.match[1].split(" ")
    return msg.send(recurry.usage.setscheduler) if args.length < 2
    id = args.shift()
    data = { scheduler: args.join(" ") }
    robot.http( recurry.url+"/scheduler/rule/"+id  )
      .header('Content-Type', 'application/json')
      .put( JSON.stringify(data) ) (err,res,body) ->
        data = JSON.parse(body)
        msg.send body 
  
  robot.respond /recurry view (.*)/i, (msg) ->
    args = msg.match[1].split(" ")
    id = args.shift()
    data = { payload: args.join(" ") }
    robot.http( recurry.url+"/scheduler/"+id  )
      .header('Content-Type', 'application/json')
      .get() (err,res,body) ->
        msg.send JSON.stringify( JSON.parse(body ),null, 2 )

  robot.respond /recurry setpayload (.*)/i, (msg) ->
    args = msg.match[1].split(" ")
    id = args.shift()
    data = { payload: args.join(" ") }
    robot.http( recurry.url+"/payload/"+id  )
      .header('Content-Type', 'application/json')
      .put( JSON.stringify(data) ) (err,res,body) ->
        data = JSON.parse(body)
        msg.send body 
  
  robot.respond /recurry scheduler (.*)/i, (msg) ->
    args = msg.match[1].split(" ")
    return msg.send("incorrect arguments received, please check help") if args.length < 2
    id = args[1]
    action = args[0]
    data = { action: action }
    console.dir data
    robot.http( recurry.url+"/scheduler/action/"+id  )
      .header('Content-Type', 'application/json')
      .put( JSON.stringify(data) ) (err,res,body) ->
        data = JSON.parse(body)
        msg.send body 

  return this


