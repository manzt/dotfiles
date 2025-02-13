(
  class_definition
    superclasses: (argument_list
      (attribute
        attribute: (identifier) @_class (#eq? @_class "AnyWidget")
      )
    )
    body: (block
      (expression_statement
        (assignment
          left: (identifier) @_prop (#eq? @_prop "_esm")
          right: (string
            (string_content) @injection.content (#set! injection.language "typescript")
          )
        )
      )
    )
)

(
  class_definition
    superclasses: (argument_list
      (attribute
        attribute: (identifier) @_class (#eq? @_class "AnyWidget")
      )
    )
    body: (block
      (expression_statement
        (assignment
          left: (identifier) @_prop (#eq? @_prop "_css")
          right: (string
            (string_content) @injection.content (#set! injection.language "css")
          )
        )
      )
    )
)
