# PureScript language support in Atom

Adds syntax highlighting to [PureScript](http://www.purescript.org) files in Atom. This grammar is also used indirectly by
GitHub highlighting via [linguist](https://github.com/github/linguist), and [VS Code](https://github.com/nwolverson/vscode-language-purescript).

Contributions are greatly appreciated. Please fork this repository and open a pull request to add snippets, make grammar tweaks, etc.

## Development

The language-purescript grammar derives originally from the language-haskell grammar, with changes to accommodate the
PureScript language and the subsequent language changes.

The grammar used by Atom is [grammars/purescript.cson](grammars/purescript.cson), but this is **generated** from
[src/purescript.coffee](src/purescript.coffee), this can be regenerated via `npm run build`.

The grammar is picked up by [regular linguist updates](https://github.com/github/linguist#theres-a-problem-with-the-syntax-highlighting-of-a-file), and via a `build` script in 
[vscode-language-purescript](https://github.com/nwolverson/vscode-language-purescript).