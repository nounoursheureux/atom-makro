
{EventEmitter} = require 'events'

module.exports =
  class Makefile extends EventEmitter

    initialize: (makefilePath) ->
      @path = makefilePath

    cmd: (target, callback) ->

      # exec our child process
      @_child = exec target, do (mV = @) ->
        (error, stdout, stderr) ->
          if error
            console.log 'error :', error

          mV._messagePanel.add new PlainMessageView
            message: "stdout : #{stdout}"
          mV._messagePanel.add new PlainMessageView
            message: "stderr : #{stderr}"

            callback(error, stdout, stderr)

      @_child.on 'error', (err) ->
        console.log 'error :', err

      signalHandler = (code, signal) ->
        console.log 'code :', code
        console.log 'signal :', signal

      @_child.on 'exit', signalHandler
      @_child.on 'close', signalHandler

      @_child.on 'disconnect', ->
        console.log 'disconnect'
