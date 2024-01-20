;; inherits: tsx
;; extends

;; Aerial: React router
(jsx_element
  open_tag: (jsx_opening_element
    name: (identifier) @_tag (#eq? @_tag "Route")
    attribute: (jsx_attribute
      (property_identifier) @_prop (#eq? @_prop "path")
      (string (string_fragment) @name)))
  (#set! "kind" "Class")
) @symbol

(jsx_self_closing_element
  name: (identifier) @_tag (#eq? @_tag "Route")
  attribute: [
    ; route path
    (jsx_attribute
      (property_identifier) @_p_path (#eq? @_p_path "path")
      (string (string_fragment) @name))

    ; index = /
    (jsx_attribute
      (property_identifier) @_p_index @name (#eq? @_p_index "index"))
  ]

  ; Select element
  attribute: (jsx_attribute
    (property_identifier) @_p_el
    (#any-of? @_p_el "element" "Component")
    (jsx_expression) @selection)?

  (#set! "kind" "Enum")
) @symbol
