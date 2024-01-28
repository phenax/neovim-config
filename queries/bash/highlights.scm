;; extends

(variable_assignment
  value: [(string) (word)] @_secret
  (#not-any-of? @_secret
     "true" "false" "yes" "no" "on" "off" "1" "0"
     "debug" "production" "debug" "test")
  (#set! conceal "*"))
