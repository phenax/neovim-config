;; extends

(block
  parameter:(expr)@org.custom.block.language)

(block
  "#+begin_"@_block_declr
  name:(expr)@_block_declr_name
  "#+end_"@_block_declr
  end_name:(expr)@_block_declr

  (#set! @_block_declr_name conceal "⌗")
  (#set! @_block_declr conceal "")
)@org.custom.block
