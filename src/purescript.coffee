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
    In case this regex seems overly general, note that PureScript
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
      /({functionNameOne})\s*(::|∷)/
    # record field may be quoted string
    recordFieldQuoted: /"(?:{className}|{functionNameOne})"/
    recordFieldDeclaration:
      /((?:[ ,])(?:{recordFieldQuoted})|{functionNameOne})\s*(::|∷)/
    ctorArgs: ///
      (?:
      {className}     #proper type
      |{functionName} #type variable
      |(?:(?:[\w()'→⇒\[\],]|->|=>)+\s*)+ #anything goes!
      )
      ///
    ctor: concat /\b({className})\s+/,
      listMaybe('ctorArgs',/{ctorArgs}/,/\s+/)
    typeDecl: /.+?/
    indentChar: /[ \t]/
    # In indent block here \1 means first captured group,
    #
    # So if the first capture block is (\s*) then end of indent block will be the line
    # with less spaced then in captured block.
    indentBlockEnd: /^(?!\1{indentChar}|{indentChar}*$)/
    maybeBirdTrack: /^/
    doubleColon: ///(?: :: | ∷ )///

  patterns: [
      include: '#module_declaration'
    ,
      include: '#module_import'
    ,
      include: '#type_synonym_declaration'
    ,
      include: '#data_type_declaration'
    ,
      include: '#typeclass_declaration'
    ,
      include: '#instance_declaration'
    ,
      include: '#derive_declaration'
    ,
      include: '#infix_op_declaration'
    ,
      include: '#foreign_import_data'
    ,
      include: '#foreign_import'
    ,
      include: '#function_type_declaration'
    ,
      include: '#function_type_declaration_arrow_first'
    ,
      include: '#typed_hole'
    ,
      include: '#keywords_orphan'
    ,
      include: "#control_keywords"
    ,
      include: '#function_infix'
    ,
      include: '#data_ctor'
    ,
      include: '#infix_op'
    ,
      include: '#constants_numeric_decimal'
    ,
      include: '#constant_numeric'
    ,
      include: '#constant_boolean'
    ,
      ### Triple quotes should come first to enclose inner quotes ###
      include: '#string_triple_quoted'
    ,
      include: '#string_single_quoted'
    ,
      include: '#string_double_quoted'
    ,
      include: '#markup_newline'
    ,
      include: '#string_double_colon_parens'
    ,
      include: '#double_colon_parens'
    ,
      include: '#double_colon_inlined'
    # ,
    #   include: '#double_colon_orphan'
    ,
      include: '#comments'
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
    module_declaration:
      patterns: [
        name: 'meta.declaration.module'
        begin: /^\s*\b(module)(?!')\b/
        end: /(\bwhere\b)/
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
      ]

    function_infix:
      patterns: [
        name: 'keyword.operator.function.infix'
        match: /(`){functionName}.*(`)/
        captures:
          1: name: 'punctuation.definition.entity'
          2: name: 'punctuation.definition.entity'
        ###
        In case this regex seems unusual for an infix operator, note
        that PureScript allows any ordinary function application (elem 4 (1..10))
        to be rewritten as an infix expression (4 `elem` (1..10)).
        ###
      ]

    typeclass_declaration:
      patterns: [
        name: 'meta.declaration.typeclass'
        begin: /^\s*\b(class)(?!')\b/
        end: /(\bwhere\b|(?=^\S))/
        beginCaptures:
          1: name: 'storage.type.class'
        endCaptures:
          1: name: 'keyword.other'
        patterns: [
          include: '#type_signature'

        ]
      ]

    instance_declaration:
      patterns: [
        name: 'meta.declaration.instance'
        begin: /^\s*\b(else\s+)?(newtype\s+)?(instance)(?!')\b/
        end: /(\bwhere\b|(?=^\S))/
        contentName: 'meta.type-signature'
        beginCaptures:
          1: name: 'keyword.other'
          2: name: 'keyword.other'
          3: name: 'keyword.other'
          4: name: 'keyword.other'
        endCaptures:
          1: name: 'keyword.other'
        patterns: [
            include: '#type_signature'
        ]
      ]

    derive_declaration:
      patterns: [
        name: 'meta.declaration.derive'
        begin: /^\s*\b(derive)(\s+newtype)?(\s+instance)?(?!')\b/
        end: /^(?=\S)/
        contentName: 'meta.type-signature'
        beginCaptures:
          1: name: 'keyword.other'
          2: name: 'keyword.other'
          3: name: 'keyword.other'
          4: name: 'keyword.other'
        endCaptures:
          1: name: 'keyword.other'
        patterns: [
            include: '#type_signature'
        ]
      ]

    foreign_import_data:
      patterns: [
        name: 'meta.foreign.data'
        begin: /^(\s*)(foreign)\s+(import)\s+(data)\s(?:\s+({classNameOne})\s*({doubleColon}))?/
        end: /{indentBlockEnd}/
        contentName: 'meta.kind-signature'
        beginCaptures:
          2: name: 'keyword.other'
          3: name: 'keyword.other'
          4: name: 'keyword.other'
          5: name: 'entity.name.type'
          6: name: 'keyword.other.double-colon'
        patterns: [
          include: '#comments'
        ,
          include: '#type_signature'
        ,
          include: '#record_types'
        ]
      ]

    foreign_import:
      patterns: [
        name: 'meta.foreign'
        begin: /^(\s*)(foreign)\s+(import)\s+({functionNameOne})/
        end: /{indentBlockEnd}/
        contentName: 'meta.type-signature'
        beginCaptures:
          2: name: 'keyword.other'
          3: name: 'keyword.other'
          4: name: 'entity.name.function'
        patterns: [
            include: '#double_colon'
          ,
            include: '#type_signature'
          ,
            include: '#record_types'
        ]
      ]

    module_import:
      patterns: [
        name: 'meta.import'
        begin: /^\s*\b(import)(?!')\b/
        end: /^(?=\S)/
        beginCaptures:
          1: name: 'keyword.other'
        patterns: [
            include: '#module_name'
          ,
            include: "#string_double_quoted"
          ,
            include: '#comments'
          ,
            include: '#module_exports'
          ,
            match: /\b(as|hiding)\b/
            captures:
              1: name: 'keyword.other'
        ]
      ]

    type_kind_signature:
      patterns: [
        name: 'meta.declaration.type.data.signature'
        begin: /{maybeBirdTrack}(data|newtype)\s+({classNameOne})\s*({doubleColon})/
        end: /(?=^\S)/
        beginCaptures:
          1: name: 'storage.type.data'
          2:
            name: 'meta.type-signature'
            patterns: [include: '#type_signature']
          3: name: 'keyword.other.double-colon'
        patterns: [
            include: '#comments'
            include: '#type_signature'
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
              # 0: name: 'punctuation.separator.pipe'
              0: name: 'keyword.operator.pipe'
          ,
            include: '#record_types'
        ]
      ]

    data_type_declaration:
      patterns: [
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
            match: /=/
            captures:
              0: name: 'keyword.operator.assignment'
          # ,
            match: /(?<=(\||=)\s*)({classNameOne})/
            captures:
              2: patterns: [include: '#data_ctor']
              # 2:
              #   name: 'meta.type-signature'
              #   patterns: [include: '#type_signature']
          ,
            match: /\|/
            captures:
              # 0: name: 'punctuation.separator.pipe'
              0: name: 'keyword.operator.pipe'
          ,
            include: '#record_types'
          ,
            include: '#type_signature'
        ]
      ]

    type_synonym_declaration:
      patterns: [
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
            match: /=/
            captures:
              0: name: 'keyword.operator.assignment'
          ,
            include: '#type_signature'
          ,
            include: '#record_types'
          ,
            include: '#row_types'
          ,
            include: '#comments'
        ]
      ]

    infix_op_declaration:
      patterns: [
        name: 'meta.infix.declaration'
        begin: /^\b(infix[l|r]?)(?!')\b/
        end: /($)/
        beginCaptures:
          1: name: 'keyword.other'
        patterns: [
            include: '#comments'
          ,
            include: '#data_ctor'
          ,
            name: 'constant.numeric'
            match: / \d+ /
          ,
            match: /({operator})/
            captures:
              1: name: 'keyword.other'
          ,
            match: /\b(type)\s+({className})\b/
            captures:
              1: name: 'keyword.other'
              2: name: 'entity.name.type'
          ,
            match: /\b(as|type)\b/
            captures:
              1: name: 'keyword.other'
        ]
      ]

    keywords_orphan:
      patterns: [
        name: 'keyword.other'
        match: /^\s*\b(derive|where|data|type|newtype|foreign(\s+import)?(\s+data)?)(?!')\b/
      ]

    typed_hole:
      patterns: [
        name: 'entity.name.function.typed-hole'
        match: /\?(?:{functionNameOne}|{classNameOne})/
      ]

    control_keywords:
      patterns: [
        name: 'keyword.control'
        # match only if a keyword is not followed by:
        # ' - names with prime symbol
        #  `:` or `=` -  records define/update
        match: /\b(do|ado|if|then|else|case|of|let|in)(?!('|\s*(:|=)))\b/
      ]

    constants_numeric_decimal:
      patterns: [
        name: 'constant.numeric.decimal.purescript'
        match: '''(?x)
            (?<!\\$)(?:
              (?:\\b[0-9]+(\\.)[0-9]+[eE][+-]?[0-9]+\\b)| # 1.1E+3
              (?:\\b[0-9]+[eE][+-]?[0-9]+\\b)|            # 1E+3
              (?:\\b[0-9]+(\\.)[0-9]+\\b)|                # 1.1
              (?:\\b[0-9]+\\b(?!\\.))                     # 1
            )(?!\\$)
          '''
        captures:
          0:
            name: 'constant.numeric.decimal.purescript'
          1:
            name: 'meta.delimiter.decimal.period.purescript'
          2:
            name: 'meta.delimiter.decimal.period.purescript'
          3:
            name: 'meta.delimiter.decimal.period.purescript'
          4:
            name: 'meta.delimiter.decimal.period.purescript'
          5:
            name: 'meta.delimiter.decimal.period.purescript'
          6:
            name: 'meta.delimiter.decimal.period.purescript'
      ]

    constant_numeric:
      patterns: [
        # I think this now just matches when underscores are present
        name: 'constant.numeric'
        match: /\b(([0-9]+_?)*[0-9]+|0([xX][0-9a-fA-F]+|[oO][0-7]+))\b/
      ]

    constant_boolean:
      patterns: [
        name: 'constant.language.boolean'
        match: /\b(true|false)(?!')\b/
      ]

    string_single_quoted:
      patterns: [
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
      ]
    # To match string that containt double colon as string, to play well with
    # #double_colon_parens rule.
    string_double_colon_parens:
      patterns: [
        match: [
          '\\(',
          '(.*?)'
          '("{character}*(::|∷)({character})*")',
        ].join('')
        captures:
          1: patterns: [
              include: '$self'
          ]
          2: patterns: [
              include: '$self'
          ]
      ]
    string_double_quoted:
      patterns: [
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
      ]

    string_triple_quoted:
      patterns: [
        name: 'string.quoted.triple'
        begin: /"""/
        end: /"""/
        beginCaptures:
          0: name: 'punctuation.definition.string.begin'
        endCaptures:
          0: name: 'punctuation.definition.string.end'
      ]

    # for inline signatures with parens
    double_colon_parens:
      patterns: [
        # Note recursive regex matching nested parens
        match: [
          '\\(',
          '(?<paren>(?:[^()]|\\(\\g<paren>\\))*)',
          '(::|∷)',
          '(?<paren2>(?:[^()}]|\\(\\g<paren2>\\))*)',
          '\\)'
        ].join('')
        captures:
          1: patterns: [
              include: '$self'
            ]
          2: name: 'keyword.other.double-colon'
          3: {name: 'meta.type-signature', patterns: [include: '#type_signature']}
      ]

    # for inline signatures without parens
    double_colon_inlined:
      patterns: [
      # signatures in ide tooptips (starts from new line)
      #   patterns: [
      #     match: '^({classNameOne})(?: +)({doubleColon})(.*)'
      #     captures:
      #       1: {name: 'meta.type-signature', patterns: [include: '#type_signature']}
      #       2: name: 'keyword.other.double-colon'
      #       3: {name: 'meta.type-signature', patterns: [include: '#type_signature']}
      #   ]
      # ,
        patterns: [
          match: '({doubleColon})(.*?)(?=<-| """)'
          captures:
            1: name: 'keyword.other.double-colon'
            2: {name: 'meta.type-signature', patterns: [
              include: '#type_signature'
            ]}
        ]
      ,
        patterns: [
          begin: '({doubleColon})'
          end: /(?=^(\s|\S))/
          beginCaptures:
            1: name: 'keyword.other.double-colon'
          patterns: [
            include: "#record_types"
            include: '#type_signature'
          ]
        ]
      ]
    double_colon_orphan:
      patterns: [
        begin: ///
          ( \s* )
          (?: ( :: | ∷ ) )
          ( \s* )
          $
          ///
        beginCaptures:
          2: name: 'keyword.other.double-colon'
        end: ///
          ^
          (?! \1 {indentChar}* | {indentChar}* $ )
          ///
        patterns: [
            include: '#type_signature'
        ]
      ]
    # double_colon_orphan:
    #   patterns: [
    #     begin: ///
    #       ( \s* )
    #       (?: ( :: | ∷ ) )
    #       ( \s* )
    #       ///
    #     beginCaptures:
    #       2: name: 'keyword.other.double-colon'
    #     end: ///
    #       ^
    #       (?! \1 {indentChar}* | {indentChar}* $ )
    #       ///
    #     patterns: [
    #         include: '#type_signature'
    #     ]
    #   ]

    markup_newline:
      patterns: [
        name: 'markup.other.escape.newline'
        match: /\\$/
      ]


    block_comment:
      patterns: [
          name: 'comment.block.documentation'
          begin: /\{-\s*\|/
          end: /-\}/
          applyEndPatternLast: 1
          beginCaptures:
            0: name: 'punctuation.definition.comment.documentation'
          endCaptures:
            0: name: 'punctuation.definition.comment.documentation'
          patterns: [
              include: '#block_comment'
          ]
        ,
          name: 'comment.block'
          begin: /\{-/
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
        #   begin: /({maybeBirdTrack}[ \t]+)?(?=--+\s*\|)/
        #   #begin: / --/
        #   # begin: /({maybeBirdTrack}[ \t]+)?(?=--+)/
        #   end: /(?!\G)/
        #   beginCaptures:
        #     1: name: 'punctuation.whitespace.comment.leading'
        #   patterns: [
        #       name: 'comment.line.double-dash.documentation'
        #       begin: /(--+)\s*(\|)/
        #       # begin: /(--+)/
        #       end: /\n/
        #       beginCaptures:
        #         1: name: 'punctuation.definition.comment'
        #         2: name: 'punctuation.definition.comment.documentation'
        #   ]
        # ,
          ###
          Operators may begin with -- as long as they are not
          entirely composed of - characters. This means comments can't be
          immediately followed by an allowable operator character.
          ###
          # begin: /({maybeBirdTrack}[ \t]+)?(?=--+(?!{operatorChar}))/
          begin: /({maybeBirdTrack}[ \t]+)?(?=--+)/
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
      begin: ///
        ^
        ( \s* )
        ( {functionNameOne} )
        \s*
        (?: ( :: | ∷ ) (?! .* <- ) )
        ///

      end: /{indentBlockEnd}/
      # end: /(?=^\S)/
      contentName: 'meta.type-signature'
      beginCaptures:
        2: name: 'entity.name.function'
        3: name: 'keyword.other.double-colon'
      patterns: [
          include: '#double_colon'
        ,
          include: '#type_signature'
        ,
          include: '#record_types'
        ,
          include: '#row_types'
      ]

    function_type_declaration_arrow_first:
      name: 'meta.function.type-declaration'
      begin: ///
        ^
        ( \s* )
        (?: \s ( :: | ∷ ) (?! .* <- ) )
        ///
      end: /{indentBlockEnd}/
      # end: /(?=^\S)/
      contentName: 'meta.type-signature'
      beginCaptures:
        2: name: 'keyword.other.double-colon'
      patterns: [
          include: '#double_colon'
        ,
          include: '#type_signature'
        ,
          include: '#record_types'
        ,
          include: '#row_types'
      ]
    row_types:
      patterns: [
        name: 'meta.type.row'
        ###
        For distinction of row type we use pattern with a space after/before a bracket,
        because there doesn't seem to be a correct way to distinguish row type declaration
        from another types put in brackets.
        ###
        # begin: /\((?= \s*({functionNameOne}|"{functionNameOne}"|"{classNameOne}")\s*(::|∷))/
        # end: / \)/
        begin: /\((?=\s*({functionNameOne}|"{functionNameOne}"|"{classNameOne}")\s*(::|∷))/
        end: /(?=^\S)/

        #applyEndPatternsLast: true
        patterns: [
            name: 'punctuation.separator.comma.purescript'
            match: ','
          ,
            include: '#comments'
          ,
            include: '#record_field_declaration'
          ,
            include: '#type_signature'
        ]
      ]

    record_types:
      patterns: [
        name: 'meta.type.record'
        # start with {, but not block comment
        begin: '\\{(?!-)'
        beginCaptures:
          0:
            name: 'keyword.operator.type.record.begin.purescript'
        end: '\\}'
        endCaptures:
          0:
            name: 'keyword.operator.type.record.end.purescript'
        patterns: [
            name: 'punctuation.separator.comma.purescript'
            match: ','
          ,
            include: '#comments'

          ,
            include: '#record_field_declaration'
          ,
            include: '#type_signature'
         ]
      ]

    record_field_declaration:
      name: 'meta.record-field.type-declaration'
      begin: /{recordFieldDeclaration}/
      # we use end pattern of " )" with space (as as row type ending)
      end: /(?={recordFieldDeclaration}|}| \)|{indentBlockEnd})/
      # applyEndPatternsLast: true
      contentName: 'meta.type-signature'
      beginCaptures:
        1:
          patterns: [
              name: 'entity.other.attribute-name'
              match: /{functionName}/
            ,
              # match quoated props
              name: 'string.quoted.double'
              match: /\"({functionNameOne}|{classNameOne})\"/
          ]
        2: name: 'keyword.other.double-colon'
      patterns: [
         include: '#record_types'
        # ,
        #   include: '#row_types'
        ,
          include: '#type_signature'
        # ,
        #   include: '#record_field_declaration'
        ,
          include: '#comments'
      ]

    # this can probalby be removed as we can use type_signature instead
    kind_signature:
      patterns: [
          name: 'keyword.other.star'
          match: /\*/
        ,
          name: 'keyword.other.exclaimation-point'
          match: /!/
        ,
          name: 'keyword.other.pound-sign'
          match: /#/
        ,
          name: 'keyword.other.arrow'
          match: /->|→/
      ]
    type_signature:
      patterns: [
         include: "#record_types"
        ,
        #  include: '#row_types'
        # ,
          name: 'meta.class-constraints'
          match: concat /\(/,
            list('classConstraints',/{classConstraint}/,/,/),
            /\)/, /\s*(=>|<=|⇐|⇒)/
          captures:
            1: patterns: [{include: '#class_constraint'}]
            #2,3 are from classConstraint
            4: name: 'keyword.other.big-arrow'
        ,
          name: 'meta.class-constraints'
          match: /({classConstraint})\s*(=>|<=|⇐|⇒)/
          captures:
            1: patterns: [{include: '#class_constraint'}]
            #2,3 are from classConstraint
            4: name: 'keyword.other.big-arrow'
        ,
          name: 'keyword.other.arrow'
          match: /(?<!{operatorChar})(->|→)/
        ,
          name: 'keyword.other.big-arrow'
          match: /(?<!{operatorChar})(=>|⇒)/
        ,
          name: 'keyword.other.big-arrow-left'
          match: /<=|⇐/
        ,
          name: 'keyword.other.forall'
          match: /forall|∀/
        ,
          include: '#string_double_quoted'
        ,
          include: '#generic_type'
        ,
          include: '#type_name'
        ,
          include: '#comments'
        ,
          name: 'keyword.other'
          match: /{operator}/
      ]
    type_name:
      name: 'entity.name.type'
      match: /\b{className}/
    data_ctor:
      name: 'entity.name.tag'
      match: /\b{className}/
    generic_type:
      name: 'variable.other.generic-type'
      match: /\b{functionName}/
    double_colon:
      name: 'keyword.other.double-colon'
      match: ///(?: :: | ∷ )///
    class_constraint:
      name: 'meta.class-constraint'
      match: /{classConstraint}/
      captures:
        1: patterns: [
          name: 'entity.name.type'
          match: /\b{className}/
        ]
        2: patterns: [
            include: '#type_name'
          ,
            include: '#generic_type'
        ]

makeGrammar purescriptGrammar, "grammars/purescript.cson"
