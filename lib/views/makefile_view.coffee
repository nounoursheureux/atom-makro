###
Dawson Reid (dreid93@gmail.com)
###

{SelectListView, EditorView, BufferedProcess} = require 'atom'
{MessagePanelView, PlainMessageView} = require 'atom-message-panel'


fs = require 'fs'
sys = require 'sys'
exec = require('child_process').exec;

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
      @addClass 'overlay from-top'
      @_cache = {}
      @_messagePanel = new MessagePanelView title: ''

    viewForItem: (item) ->
      return "<li>#{item}</li>"

    # launch the make process
    confirmed: (item) ->
      console.log "#{item} was selected"
      @_messagePanel.setTitle "#{@makefile} #{item}"
      @_messagePanel.attach()

      command = "cd #{atom.project.getRootDirectory().path} && make #{item}"
      console.log command

      # exec our child process
      child = exec command, do (mV = @) ->
        (error, stdout, stderr) ->
          if error
            console.log 'error :', error

          mV._messagePanel.add new PlainMessageView
            message: "stdout : #{stdout}"
          mV._messagePanel.add new PlainMessageView
            message: "stderr : #{stderr}"

      child.on 'error', (err) ->
        console.log 'error :', err

      signalHandler = (code, signal) ->
        console.log 'code :', code
        console.log 'signal :', signal

      child.on 'exit', signalHandler
      child.on 'close', signalHandler

      child.on 'disconnect', ->
        console.log 'disconnect'

      child.on 'message', (object, sendHandle) ->

    ###
    The arguement is a Atom File object. The makefile reference is only to the
    file path of the makefile because the object is not required.
    ###
    setMakefile: (makefile) ->
      console.log 'set makefile :', makefile
      @makefile = makefile
      @title.text("#{makefile.path}")

      @makefile.once 'pre-load', do (mV = @) ->
        () ->
          mV.setLoading 'Parsing and loading Makefile targets.'

      @makefile.once 'post-load', do (mV = @) ->
        (targets) ->
          mV.setItems targets

      @makefile.targets() # compute targets

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
