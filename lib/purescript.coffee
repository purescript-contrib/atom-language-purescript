{MessagePanelView, PlainMessageView} = require 'atom-message-panel'
_                                    = require 'underscore'

module.exports =

  activate: ->
    pkgHs     = 'language-haskell'
    pkgPsc    = 'language-purescript'

    errorMsgsView = new MessagePanelView(title: "#{pkgPsc}")
    errorMsgs     = []

    if _.include(atom.packages.getAvailablePackageNames(), pkgHs)
      if atom.packages.isPackageDisabled(pkgHs)
        errorMsgs.push new PlainMessageView
          message:   "\'#{pkgHs}\' must be enabled for \'#{pkgPsc}\' to function"
          className: 'text-error'
    else
        errorMsgs.push new PlainMessageView
          message:   "\'#{pkgHs}\' must be installed for \'#{pkgPsc}\' to function"
          className: 'text-error'

    errorMsgs.map((msg) -> errorMsgsView.add(msg))
    errorMsgsView.attach() if errorMsgs.length > 0

  deactivate: ->
    console.log 'deactivate'

  serialize: ->
    console.log 'serialize'
