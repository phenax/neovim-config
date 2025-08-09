(local mini-surround (require :mini.surround))

(fn config []
  (mini-surround.setup {:mappings {:add :sa
                                   :delete :sd
                                   :find :sf
                                   :find_left :sF
                                   :highlight :sh
                                   :replace :sc
                                   :suffix_last :l
                                   :suffix_next :n}
                        :n_lines 40
                        :respect_selection_type true}))

{: config}
