(local autopairs (require :nvim-autopairs))

(fn config []
  (autopairs.setup {:disable_filetype [:snacks_picker_input]
                    :map_c_h true
                    :map_c_w true}))

{: config}
