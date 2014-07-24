
{EventEmitter} = require 'events'
{exec} = require 'child_process'
fs = require 'fs'

module.exports =
  class Makefile extends EventEmitter

    ###
    Takes a Atom File object.
    ###
    constructor: (file) ->
      @path = file.path

    targets: ->
      if not @_targets
        @_parseMakefile()
      else
        @emit 'post-load', Object.keys @_targets

    ###
    @_targets is a cache of the targets available within this Makefile. A map
    is used to effeciently emulate a set.
    ###
    _parseMakefile: ->
      console.log 'load makefile targets'
      @emit 'pre-load'

      # use an object for the cache to imitate a set datastructure
      @_targets = {}
      fs.readFile @path, do (mf = @) ->
        (err, data) ->
          if err
            console.log 'error reading makefile :', makefile.path
            return

          makefileContents = data.toString().split '\n'
          for line in makefileContents # search each line for a target
            matches = line.match /(^[a-zA-Z-]{1,}?):/

            # if it matches and it's not already in the cache
            if matches and matches[1] not in mf._targets
              makefileTarget = matches[1]
              #console.log makefileTarget

              # add it to the cache
              mf._targets[makefileTarget] = makefileTarget

          mf.targets() # run targets to emit post-load event

    run: (target, callback) ->

      # exec our child process
      command = "cd #{atom.project.getRootDirectory().path} && make #{target}"
      console.log @
      @emit 'pre-run', target
      @_child = exec command, do (mF = @) ->
        (error, stdout, stderr) ->
          mF.emit 'post-run', target
          callback error, stdout, stderr

      @_child.on 'error', (err) ->
        console.log 'error :', err

      signalHandler = (code, signal) ->
        console.log 'code :', code
        console.log 'signal :', signal

      @_child.on 'exit', signalHandler
      @_child.on 'close', signalHandler

      @_child.on 'disconnect', ->
        console.log 'disconnect'
