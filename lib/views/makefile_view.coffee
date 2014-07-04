###
Dawson Reid (dreid93@gmail.com)
###

{SelectListView} = require 'atom'
{EditorView} = require 'atom'
fs = require 'fs'

module.exports =
  class MakefileView extends SelectListView

    # Overriden to add title bar to search view.
    @content: ->
      @div class: 'select-list', =>
        @div class: 'panel-heading', outlet: 'title'
        @subview 'filterEditorView', new EditorView(mini: true)
        @div class: 'error-message', outlet: 'error'
        @div class: 'loading', outlet: 'loadingArea', =>
          @span class: 'loading-message', outlet: 'loading'
          @span class: 'badge', outlet: 'loadingBadge'
        @ol class: 'list-group', outlet: 'list'

    initialize: ->
      super
      @addClass('overlay from-top')
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

            mV.loadListFromCache(mV.makefile)
      else
        @loadListFromCache(@makefile)

    loadListFromCache: (makefile) ->
      @title.text("#{makefile}")
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
