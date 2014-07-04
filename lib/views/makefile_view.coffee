###
Dawson Reid (dreid93@gmail.com)
###

{SelectListView} = require 'atom'
fs = require 'fs'

module.exports =
  class MakefileView extends SelectListView

    initialize: ->
      super
      @addClass('overlay from-top')
      @setItems(['Hello', 'World'])

      @_cache = {}

    viewForItem: (item) ->
      return "<li>#{item}</li>"

    confirmed: (item) ->
      console.log("#{item} was selected")

    ###
    The arguement is a Atom File object. The makefile reference is only to the
    file path of the makefile because the object is not required.
    ###
    setMakefile: (makefile) ->
      console.log 'set makefile :', makefile
      if @makefile and @makefile == makefile.path
        console.log 'previously set makefile'
      else
        @makefile = makefile.path

        if @makefile not in @_cache
          # use an object for the cache to imitate a set datastructure
          @_cache[@makefile] = {}
          fs.readFile @makefile, do (mV = @) ->
            (err, data) ->
              if err
                console.log 'error reading makefile :', makefile.path
                return

              makefileContents = data.toString().split '\n'
              for line in makefileContents # search each line for a target
                matches = line.match /([a-zA-Z-]{1,}?):/

                # if it matches and it's not already in the cache
                if matches and matches[1] not in mV._cache[mV.makefile]
                  makefileTarget = matches[1]
                  #console.log makefileTarget

                  # add it to the cache
                  mV._cache[mV.makefile][makefileTarget] = makefileTarget

              mV.loadListFromCache()
        else
          @loadListFromCache()

    loadListFromCache: ->
      @setItems Object.keys @_cache[@makefile]

    open: ->
      atom.workspaceView.append(this)
      @focusFilterEditor()

    close: ->
      @detach()

    isOpen: ->
      @hasParent()

    toggle: ->
      if @isOpen()
        @close()
      else
        @open()
