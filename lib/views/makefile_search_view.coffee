###
Dawson Reid (dreid93@gmail.com)
###

{SelectListView, EditorView, BufferedProcess} = require 'atom'

fs = require 'fs'

module.exports =
  class MakefileSearchView extends SelectListView

    # Overriden to add title bar to search view.
    @content: ->
      @div class: 'select-list', =>
        @div
          class: 'panel-heading',
          'Selet a Makefile'
        @subview 'filterEditorView', new EditorView(mini: true)
        @div class: 'error-message', outlet: 'error'
        @div class: 'loading', outlet: 'loadingArea', =>
          @span class: 'loading-message', outlet: 'loading'
          @span class: 'badge', outlet: 'loadingBadge'
        @ol class: 'list-group', outlet: 'list'

    initialize: (makefileView) ->
      super
      @addClass 'overlay from-top'
      @makefileView = makefileView

    viewForItem: (item) ->
      return "<li>#{item}</li>"

    confirmed: (makefile) ->
      console.log 'selected :', makefile

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
