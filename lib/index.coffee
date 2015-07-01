###
# This file is the entry point of your package. It will be loaded once as a
# singleton.

Dawson Reid (dreid93@gmail.com)
###

MakefileView = require './views/makefile_view'
MakefileSearchView = require './views/makefile_search_view'

module.exports =

  ###
  # This required method is called when your package is activated.
  ###
  activate: (state) ->
    @makefileView = new MakefileView()
    @makefileSearchView = new MakefileSearchView @makefileView

    atom.commands.add 'atom-workspace', 'makro:toggleMainMakefile', => @toggleMainMakefile()
    atom.commands.add 'atom-workspace', 'makro:toggleMakefileSearch', => @makefileSearchView.toggle()

  ###
  # This optional method is called when the window is shutting down, allowing
  # you to return JSON to represent the state of your component.
  ###
  serialize: ->
    console.log 'serialize()'

  ###
  # This optional method is called when the window is shutting down.
  ###
  deactivate: ->
    console.log 'deactivate()'

  loadMakefile: (cb) ->
    console.log 'loading'
    directory = atom.project.getDirectories()[0]

    directory.getEntries do (makro = @) ->
      (err, entries) ->
        if err
          console.log 'Error :', err

        for entry in entries
          if entry.isFile() and entry.getBaseName() == 'Makefile'
            console.log 'found main makefile'

            Makefile = require './models/makefile'
            mainMakefile = new Makefile(entry)
            cb(mainMakefile)

    console.log directory
    cb()


  toggleMainMakefile: ->
    console.log 'makro.toggleMainMakefile'
    if not @makefileView.makefile
      @loadMakefile (makefile) =>
        if makefile
          @makefileView.setMakefile(makefile)
          @makefileView.toggle()
        else
          @makefileSearchView.toggle()
    else
      @makefileView.toggle()
