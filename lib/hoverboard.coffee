ws = require "ws"
http = require 'http'
express = require "express"
eventTap = require "event-tap"

appServer = express()
httpServer = http.createServer appServer
socketServer = new ws.Server({server: httpServer})

appServer.configure ->
  appServer.use express.methodOverride()
  appServer.use express.bodyParser()
  appServer.set 'view engine', 'ejs'
  appServer.use require('connect-assets')({src: __dirname + "/../assets"})
  appServer.use express.static(__dirname + '/../static');
  appServer.use express.errorHandler({dumpExceptions: true, showStack: true })
  appServer.use appServer.router

appServer.get '/', (req, res) ->
  res.render 'index'

socketServer.on 'connection', (socket) ->
  socket.on 'message', (message) ->
    data = JSON.parse message

    if data.type == 'keydown'
      eventTap.postKeyboardEvent parseInt(data.keyCode)

exports.start = (port=8080) -> httpServer.listen(8080)
