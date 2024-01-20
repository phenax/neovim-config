;; inherits: ruby
;; extends

(call
  method: (identifier) @_method
  (#any-of? @_method
    "namespace" "resources" "get" "post" "put" "patch" "delete" "root" "match" "scope" "mount")
  arguments: (argument_list (_) @name)
  (#set! "kind" "Class")
  (#has-ancestor? @name do_block)
) @symbol
