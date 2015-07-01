###
Dawson Reid (dreid93@gmail.com)
###

{BufferedProcess, File} = require 'atom'
{SelectListView, TextEditorView} = require 'atom-space-pen-views'
fs = require 'fs'
Makefile = require '../models/makefile'

module.exports =
  class MakefileView extends SelectListView

    # Overriden to add title bar to search view.
    @content: ->
      @div class: 'select-list', =>
        @div
          class: 'panel-heading',
          'Select a Makefile'
        @subview 'filterEditorView', new TextEditorView(mini: true)
        @div class: 'error-message', outlet: 'error'
        @div class: 'loading', outlet: 'loadingArea', =>
          @span class: 'loading-message', outlet: 'loading'
          @span class: 'badge', outlet: 'loadingBadge'
        @ol class: 'list-group', outlet: 'list'

    initialize: (makefileView) ->
      super
      @addClass 'overlay from-top'
      @panel = atom.workspace.addModalPanel(item: this, visible: false)
      @makefileView = makefileView
      atom.commands.add @filterEditorView.element, 'core:cancel', => @close()

    checkDirectories: ->
      return new Promise (resolve, reject) =>
        promises = []
        for dir in atom.project.getDirectories()
          promises.push @checkDirectory(dir)

        Promise.all(promises).then ->
          resolve()
        , (error) ->
          reject error

    checkDirectory: (directory) ->
      return new Promise (resolve, reject) =>
        promises = []
        atom.project.repositoryForDirectory(directory).then (repo) =>
          directory.getEntries (err, entries) =>
            throw err if err
            for entry in entries
              if repo && repo.isPathIgnored(entry.getRealPathSync()) then continue
              if entry.isFile() && entry.getBaseName() == "Makefile"
                entry.getRealPath().then (path) =>
                  @makefiles.push(path)
              else if entry.isDirectory()
                promises.push @checkDirectory(entry)
            Promise.all(promises).then ->
              resolve()
            , (error) ->
              reject error

    viewForItem: (item) ->
      return "<li>#{item}</li>"

    confirmed: (path) ->
      file = new File(path, false)
      makefile = new Makefile(file)
      @makefileView.setMakefile(makefile)
      @close()

    open: ->
      @makefiles = []
      @checkDirectories().then =>
        @setItems(@makefiles)
        @panel.show()
        @focusFilterEditor()
      , (error) ->
        throw error

    close: ->
      @panel.hide()
      @filterEditorView.setText('')

    isOpen: ->
      @panel.isVisible()

    toggle: ->
      if @isOpen()
        @close()
      else
        @open()
