# Run this file to regenerate the grammars/purescript.cson file, as follows:
# $ ./node_modules/.bin/coffee src/purescript.coffee

makeGrammar = require './syntax-tools'

toString = (rx) ->
  if rx instanceof RegExp
    rx.source
  else
    rx

list = (item,s,sep) ->
  #recursive regexp, caution advised
  "(?<#{item}>(?:#{toString s})(?:\\s*(?:#{toString sep})\\s*\\g<#{item}>)?)"

listMaybe = (item,s,sep) ->
  #recursive regexp, caution advised
  "(?<#{item}>(?:#{toString s})(?:\\s*(?:#{toString sep})\\s*\\g<#{item}>)?)?"

concat = (list...) ->
  r=''.concat (list.map (i) -> "(?:#{toString i})")...
  "(?:#{r})"

purescriptGrammar =
  name: 'PureScript'
  fileTypes: [ 'purs' ]
  scopeName: 'source.purescript'

  macros:
    functionNameOne: /[\p{Ll}_][\p{Ll}_\p{Lu}\p{Lt}\p{Nd}']*/
    classNameOne: /[\p{Lu}\p{Lt}][\p{Ll}_\p{Lu}\p{Lt}\p{Nd}']*/
    functionName: /(?:{className}\.)?{functionNameOne}/
    className: /{classNameOne}(?:\.{classNameOne})*/
    operatorChar: /[\p{S}\p{P}&&[^(),;\[\]`{}_"']]/
    ###
    In case this regex seems overly general, note that Haskell
    permits the definition of new operators which can be nearly any string
    of punctuation characters, such as $%^&*.
    ###
    operator: /{operatorChar}+/
    operatorFun: ///
      (?:
        \(
          (?!--+\)) # An operator cannot be composed entirely of `-` characters
          {operator}
        \)
      )
      ///
    character: ///
      (?:
        [\ -\[\]-~]                # Basic Char
        | (\\(?:NUL|SOH|STX|ETX|EOT|ENQ|ACK|BEL|BS|HT|LF|VT|FF|CR|SO|SI|DLE
          |DC1|DC2|DC3|DC4|NAK|SYN|ETB|CAN|EM|SUB|ESC|FS|GS|RS
          |US|SP|DEL|[abfnrtv\\\"'\&]))    # Escapes
        | (\\o[0-7]+)                # Octal Escapes
        | (\\x[0-9A-Fa-f]+)            # Hexadecimal Escapes
        | (\^[A-Z@\[\]\\\^_])            # Control Chars
      )
      ///
    classConstraint: concat /({className})\s+/,
      list('classConstraint',/{className}|{functionName}/,/\s+/)
    functionTypeDeclaration:
      concat list('functionTypeDeclaration',/{functionName}|{operatorFun}/,/,/),
        /\s*(::|∷)/
    ctorArgs: ///
      (?!deriving)
      (?:
      {className}     #proper type
      |{functionName} #type variable
      |(?:(?!deriving)(?:[\w()'→⇒\[\],]|->|=>)+\s*)+ #anything goes!
      )
      ///
    ctor: concat /\b({className})\s+/,
      listMaybe('ctorArgs',/{ctorArgs}/,/\s+/)
    typeDecl: /.+?/
    indentChar: /[ \t]/
    indentBlockEnd: /^(?!\1{indentChar}|{indentChar}*$)/
    maybeBirdTrack: /^/

  patterns: [
      name: 'keyword.operator.function.infix'
      match: /(`){functionName}(`)/
      captures:
        1: name: 'punctuation.definition.entity'
        2: name: 'punctuation.definition.entity'
      ###
      In case this regex seems unusual for an infix operator, note
      that Haskell allows any ordinary function application (elem 4 [1..10])
      to be rewritten as an infix expression (4 `elem` [1..10]).
      ###
    ,
      begin: /(\[)({functionNameOne})(\|)/
      end: /(\|)(\])/
      beginCaptures:
        1: name: 'punctuation.definition.quasiquotes.begin'
        2: name: 'entity.name.tag'
        3: name: 'string.quoted.quasiquotes'
      endCaptures:
        1: name: 'string.quoted.quasiquotes'
        2: name: 'punctuation.definition.quasiquotes.end'
      contentName: 'string.quoted.quasiquotes'
    ,
      name: 'meta.declaration.module'
      begin: /\b(module)\b/
      end: /(where)/
      beginCaptures:
        1: name: 'keyword.other'
      endCaptures:
        1: name: 'keyword.other'
      patterns: [
          include: '#comments'
        ,
          include: '#module_name'
        ,
          include: '#module_exports'
        ,
          name: 'invalid'
          match: /[a-z]+/
      ]
    ,
      name: 'meta.declaration.typeclass'
      begin: /\b(class)\b/
      end: /\b(where)\b|$/
      beginCaptures:
        1: name: 'storage.type.class'
      endCaptures:
        1: name: 'keyword.other'
      patterns: [
        include: '#type_signature'
      ]
    ,
      name: 'meta.declaration.instance'
      begin: /\b(instance)\b/
      end: /\b(where)\b|$/
      contentName: 'meta.type-signature'
      beginCaptures:
        1: name: 'keyword.other'
      endCaptures:
        1: name: 'keyword.other'
      patterns: [
          include: '#type_signature'
      ]
    ,
      name: 'meta.foreign'
      begin: /{maybeBirdTrack}(\s*)(foreign)\s+(import)\b/
      end: /{indentBlockEnd}/
      beginCaptures:
        2: name: 'keyword.other'
        3: name: 'keyword.other'
      patterns:[
          include: '#type_signature'
        ,
          include: '$self'
      ]
    ,
      name: 'meta.import'
      begin: /\b(import)\b/
      end: /($|;|(?=--))/
      beginCaptures:
        1: name: 'keyword.other'
      patterns: [
          include: '#module_name'
        ,
          include: '#module_exports'
        ,
          match: /\b(qualified|as|hiding)\b/
          captures:
            1: name: 'keyword.other'
      ]
    ,
      name: 'meta.declaration.type.data'
      begin: /{maybeBirdTrack}(\s)*(data|newtype)\s+({typeDecl})\s*(?=\=|$)/
      end: /{indentBlockEnd}/
      beginCaptures:
        2: name: 'storage.type.data'
        3:
          name: 'meta.type-signature'
          patterns: [include: '#type_signature']
      patterns: [
          include: '#comments'
        ,
          include: '#deriving'
        ,
          match: /=/
          captures:
            0: name: 'keyword.operator.assignment'
        ,
          match: /{ctor}/
          captures:
            1: patterns: [include: '#data_ctor']
            2:
              name: 'meta.type-signature'
              patterns: [include: '#type_signature']
        ,
          match: /\|/
          captures:
            0: name: 'punctuation.separator.pipe'
        ,
          name: 'meta.declaratyion.type.data.record.block'
          begin: /\{/
          beginCaptures:
            0: name: 'keyword.operator.record.begin'
          end: /\}/
          endCaptures:
            0: name: 'keyword.operator.record.end'
          patterns: [
              name: 'punctuation.separator.comma'
              match: /,/
            ,
              include: '#record_field_declaration'
          ]
      ]
    ,
      name: 'meta.declaration.type.type'
      begin: /{maybeBirdTrack}(\s)*(type)\s+({typeDecl})\s*(?=\=|$)/
      end: /{indentBlockEnd}/
      contentName: 'meta.type-signature'
      beginCaptures:
        2: name: 'storage.type.data'
        3:
          name: 'meta.type-signature'
          patterns: [include: '#type_signature']
      patterns: [
          include: '#comments'
        ,
          match: /=/
          captures:
            0: name: 'keyword.operator.assignment'
        ,
          include: '#type_signature'
      ]
    ,
      name: 'keyword.other'
      match: /\b(deriving|where|data|type|newtype)\b/
    ,
      name: 'storage.type'
      match: /\b(data|type|newtype)\b/
    ,
      name: 'keyword.operator'
      match: /\binfix[lr]?\b/
    ,
      name: 'keyword.control'
      match: /\b(do|if|then|else|case|of|let|in|default)\b/
    ,
      name: 'constant.numeric.float'
      match: /\b([0-9]+\.[0-9]+([eE][+-]?[0-9]+)?|[0-9]+[eE][+-]?[0-9]+)\b/
      # Floats are always decimal
    ,
      name: 'constant.numeric'
      match: /\b([0-9]+|0([xX][0-9a-fA-F]+|[oO][0-7]+))\b/
    ,
      name: 'string.quoted.double'
      begin: /"/
      end: /"/
      beginCaptures:
        0: name: 'punctuation.definition.string.begin'
      endCaptures:
        0: name: 'punctuation.definition.string.end'
      patterns: [
          include: '#characters'
        ,
          begin: /\\\s/
          end: /\\/
          beginCaptures:
            0: name: 'markup.other.escape.newline.begin'
          endCaptures:
            0: name: 'markup.other.escape.newline.end'
          patterns: [
              match: /\S+/
              name: 'invalid.illegal.character-not-allowed-here'
          ]
      ]
    ,
      name: 'markup.other.escape.newline'
      match: /\\$/
    ,
      name: 'string.quoted.single'
      match: /(')({character})(')/
      captures:
        1: name: 'punctuation.definition.string.begin'
        2:
          patterns:[
            include: '#characters'
          ]
        # {character} macro has 4 capture groups, here 3-6
        7: name: 'punctuation.definition.string.end'
    ,
      include: '#function_type_declaration'
    ,
      include: '#data_ctor'
    ,
      include: '#comments'
    ,
      include: '#infix_op'
    ,
      name: 'keyword.other.arrow'
      match: /\<-|-\>/
    ,
      name: 'keyword.operator'
      match: /{operator}/
    ,
      name: 'punctuation.separator.comma'
      match: /,/
  ]
  repository:
    block_comment:
      patterns: [
          name: 'comment.block.haddock'
          begin: /\{-\s*[|^]/
          end: /-\}/
          applyEndPatternLast: 1
          beginCaptures:
            0: name: 'punctuation.definition.comment.haddock'
          endCaptures:
            0: name: 'punctuation.definition.comment.haddock'
          patterns: [
              include: '#block_comment'
          ]
        ,
          name: 'comment.block'
          begin: /\{-(?!#)/
          end: /-\}/
          applyEndPatternLast: 1
          beginCaptures:
            0: name: 'punctuation.definition.comment'
          patterns: [
              include: '#block_comment'
          ]
      ]
    comments:
      patterns: [
          begin: /({maybeBirdTrack}[ \t]+)?(?=--+\s+[|^])/
          end: /(?!\G)/
          beginCaptures:
            1: name: 'punctuation.whitespace.comment.leading'
          patterns: [
              name: 'comment.line.double-dash.haddock'
              begin: /(--+)\s+([|^])/
              end: /\n/
              beginCaptures:
                1: name: 'punctuation.definition.comment'
                2: name: 'punctuation.definition.comment.haddock'
          ]
        ,
          ###
          Operators may begin with -- as long as they are not
          entirely composed of - characters. This means comments can't be
          immediately followed by an allowable operator character.
          ###
          begin: /({maybeBirdTrack}[ \t]+)?(?=--+(?!{operatorChar}))/
          end: /(?!\G)/
          beginCaptures:
            1: name: 'punctuation.whitespace.comment.leading'
          patterns: [
              name: 'comment.line.double-dash'
              begin: /--/
              end: /\n/
              beginCaptures:
                0: name: 'punctuation.definition.comment'
          ]
        ,
          include: '#block_comment'
      ]
    characters:
      match: /{character}/
      captures:
        1: name: 'constant.character.escape'
        2: name: 'constant.character.escape.octal'
        3: name: 'constant.character.escape.hexadecimal'
        4: name: 'constant.character.escape.control'
    infix_op:
      name: 'entity.name.function.infix'
      match: /{operatorFun}/
    module_exports:
      name: 'meta.declaration.exports'
      begin: /\(/
      end: /\)/
      patterns: [
          include: '#comments'
        ,
          name: 'entity.name.function'
          match: /\b{functionName}/
        ,
          include: '#type_name'
        ,
          name: 'punctuation.separator.comma'
          match: /,/
        ,
          include: '#infix_op'
        ,
          name: 'meta.other.constructor-list'
          match: /\(.*?\)/
      ]
    module_name:
      name: 'support.other.module'
      match: /(?:{className}\.)*{className}\.?/
    function_type_declaration:
      name: 'meta.function.type-declaration'
      begin: concat /{maybeBirdTrack}(\s*)/,/{functionTypeDeclaration}/
      end: /{indentBlockEnd}/
      contentName: 'meta.type-signature'
      beginCaptures:
        2:
          patterns: [
              name: 'entity.name.function'
              match: /{functionName}/
            ,
              include: '#infix_op'
          ]
        3: name: 'keyword.other.double-colon'
      patterns: [
          include: '#type_signature'
      ]
    record_field_declaration:
      name: 'meta.record-field.type-declaration'
      begin: /{functionTypeDeclaration}/
      end: /(?={functionTypeDeclaration}|})/
      contentName: 'meta.type-signature'
      beginCaptures:
        1:
          patterns: [
              name: 'entity.other.attribute-name'
              match: /{functionName}/
            ,
              include: '#infix_op'
          ]
        2: name: 'keyword.other.double-colon'
      patterns: [
          include: '#type_signature'
      ]
    type_signature:
      patterns: [
          name: 'meta.class-constraints'
          match: concat /\(/,
            list('classConstraints',/{classConstraint}/,/,/),
            /\)/, /\s*(=>|<=|⇒)/
          captures:
            1: patterns: [{include: '#class_constraint'}]
            #2,3 are from classConstraint
            4: name: 'keyword.other.big-arrow'
        ,
          name: 'meta.class-constraints'
          match: /({classConstraint})\s*(=>|<=|⇒)/
          captures:
            1: patterns: [{include: '#class_constraint'}]
            #2,3 are from classConstraint
            4: name: 'keyword.other.big-arrow'
        ,
          name: 'keyword.other.arrow'
          match: /->|→/
        ,
          name: 'keyword.other.big-arrow'
          match: /=>|⇒/
        ,
          name: 'keyword.other.big-arrow-left'
          match: /<=/
        ,
          name: 'keyword.other.forall'
          match: /forall/
        ,
          include: '#generic_type'
        ,
          include: '#type_name'
        ,
          include: '#comments'
      ]
    type_name:
      name: 'entity.name.type'
      match: /\b{className}\b/
    data_ctor:
      name: 'entity.name.tag'
      match: /\b{className}\b/
    generic_type:
      name: 'variable.other.generic-type'
      match: /\b{functionName}\b/
    class_constraint:
      name: 'meta.class-constraint'
      match: /{classConstraint}/
      captures:
        1: patterns: [
          name: 'entity.name.type'
          match: /\b{className}\b/
        ]
        2: patterns: [
            include: '#type_name'
          ,
            include: '#generic_type'
        ]
    deriving:
      patterns: [
          include: '#deriving_list'
        ,
          include: '#deriving_simple'
        ,
          include: '#deriving_keyword'
      ]
    deriving_keyword:
      name: 'meta.deriving'
      match: /(deriving)/
      captures:
        1: name: 'keyword.other'
    deriving_list:
      name: 'meta.deriving'
      begin: /(deriving)\s*\(/
      end: /\)/
      beginCaptures:
        1: name: 'keyword.other'
      patterns: [
          match: /\b({className})\b/
          captures:
            1: name: 'entity.name.type'
      ]
    deriving_simple:
      name: 'meta.deriving'
      match: /(deriving)\s*({className})/
      captures:
        1: name: 'keyword.other'
        2: name: 'entity.name.type'

makeGrammar purescriptGrammar, "grammars/purescript.cson"
