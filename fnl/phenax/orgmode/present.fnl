(local {: not_nil?} (require :phenax.utils.utils))

(local present {:buffer nil
                :config {:height (fn [h] (if (<= h 15) (* h 0.8) (* h 0.7)))
                         :width (fn [w] (if (<= w 100) (* w 0.8) (* w 0.6)))}
                :content_buffer nil
                :group nil
                :namespace_id (vim.api.nvim_create_namespace :phenax/orgmodepresent)
                :state {:current_slide 1 :slides [{}]}
                :window nil})

(var empty-buffer nil)
(var background nil)

(local Slide {})

(fn Slide.new [self o] (setmetatable o self) (set self.__index self) o)
(fn Slide.get_lines [self] self.lines)

(fn present.initialize [config]
  (set present.config (vim.tbl_extend :force present.config (or config {})))
  (vim.api.nvim_set_hl present.namespace_id :NormalFloat
                       {:bg :none :fg "#ffffff"})
  (vim.api.nvim_set_hl present.namespace_id :NormalNC {:bg :none :fg "#ffffff"})
  (vim.api.nvim_set_hl present.namespace_id :Title
                       {:bg "#4e3aA3" :bold true :fg "#ffffff"})
  (vim.api.nvim_set_hl present.namespace_id "@org.custom.block.language"
                       {:fg "#4e3aA3"})
  present)

(fn present.present [buffer]
  (set present.content_buffer
       (if (and (not_nil? buffer) (not= buffer 0)) buffer
           (vim.api.nvim_get_current_buf)))
  (set present.state.slides (present.prepare_slides))
  (set present.group
       (vim.api.nvim_create_augroup :phenax/orgmodepresent {:clear true}))
  (present.create_background)
  (local slide-buf (present.create_slide_buffer))
  (present.create_window slide-buf)
  (present.configure)
  (vim.api.nvim_create_autocmd :WinResized
                               {:callback (fn [] (present.configure))
                                :group present.group}))

(fn present.get_sections [node]
  (local sections {})
  (each [_ child (ipairs (node:named_children))]
    (when (= (child:type) :section) (table.insert sections child)))
  sections)

(fn present.get_directives [root buffer]
  (let [directives {}]
    (each [_ child (ipairs (root:named_children))]
      (when (= (child:type) :body)
        (each [_ body-ch (ipairs (child:named_children))]
          (when (and (= (body-ch:type) :directive)
                     (>= (body-ch:named_child_count) 2))
            (local name
                   (vim.treesitter.get_node_text (body-ch:named_child 0) buffer))
            (local value
                   (vim.treesitter.get_node_text (body-ch:named_child 1) buffer))
            (tset directives name value)))))
    directives))

(fn present.prepare_slides []
  (let [parser (vim.treesitter.get_parser present.content_buffer :org {})
        root (: (. (parser:parse) 1) :root)
        sections (present.get_sections root)
        directives (present.get_directives root present.content_buffer)]
    (fn to-slide [node]
      (let [(startr _ endr _) (vim.treesitter.get_node_range node)
            lines (vim.api.nvim_buf_get_lines present.content_buffer startr
                                              endr false)]
        (Slide:new {: lines :name "--"})))

    (local slides (vim.tbl_map to-slide sections))
    (when directives.title
      (local intro-heading (present.figlet_block directives.title))
      (local intro (Slide:new {:lines intro-heading :name :Intro}))
      (table.insert slides 1 intro))
    (local outro-heading
           (present.figlet_block (or directives.outro "End of presentation")))
    (local outro (Slide:new {:lines outro-heading :name :Outro}))
    (table.insert slides outro)
    slides))

(fn present.figlet_block [text]
  (let [block (present.figlet text)] (table.insert block 1 "#+begin_src")
    (table.insert block "#+end_src")
    block))

(fn present.figlet [text]
  (let [w (present.config.width vim.o.columns)
        cmd [:figlet :-c :-w w text]
        result (: (vim.system cmd {}) :wait)
        lines {}]
    (each [line (string.gmatch result.stdout "[^\n]+")]
      (table.insert lines line))
    lines))

(fn present.create_slide_buffer []
  (set present.buffer (vim.api.nvim_create_buf false true))
  (vim.api.nvim_set_option_value :filetype :org {:buf present.buffer})
  (local opts {:buffer present.buffer :nowait true})
  (vim.keymap.set :n :q (fn [] (present.close)) opts)
  (vim.keymap.set :n :n (fn [] (present.next_slide)) opts)
  (vim.keymap.set :n :p (fn [] (present.previous_slide)) opts)
  present.buffer)

(fn present.next_slide []
  (present.set_slide_index (+ present.state.current_slide 1)))

(fn present.previous_slide []
  (present.set_slide_index (- present.state.current_slide 1)))

(fn present.set_slide_index [index]
  (when (<= index 0) (lua "return "))
  (when (> index (length present.state.slides)) (lua "return "))
  (set present.state.current_slide index)
  (local slide (. present.state.slides present.state.current_slide))
  (vim.api.nvim_buf_set_lines present.buffer 0 (- 1) false (slide:get_lines))
  (print (.. "Slide: " present.state.current_slide "/"
             (length present.state.slides))))

(fn present.create_background []
  (set empty-buffer (vim.api.nvim_create_buf false true))
  (set background (vim.api.nvim_open_win empty-buffer false
                                         {:col 0
                                          :focusable false
                                          :height 1
                                          :relative :editor
                                          :row 0
                                          :style :minimal
                                          :width 1
                                          :zindex 100}))
  (vim.api.nvim_win_set_hl_ns background present.namespace_id))

(fn present.create_window [buffer]
  (set present.window
       (vim.api.nvim_open_win buffer true
                              {:col 5
                               :focusable true
                               :height 10
                               :relative :editor
                               :row 5
                               :style :minimal
                               :width 50
                               :zindex 110}))
  (vim.api.nvim_win_set_hl_ns present.window present.namespace_id)
  (vim.api.nvim_set_option_value :winfixbuf true {:win present.window})
  (vim.api.nvim_set_option_value :conceallevel 2 {:win present.window})
  (vim.api.nvim_set_option_value :concealcursor :nvc {:win present.window})
  (vim.api.nvim_set_option_value :listchars "" {:win present.window}))

(fn present.configure []
  (set present.state.slides (present.prepare_slides))
  (present.set_slide_index present.state.current_slide)
  (local width vim.o.columns)
  (local height vim.o.lines)
  (local slide-width (math.floor (present.config.width width)))
  (local slide-height (math.floor (present.config.height height)))
  (vim.api.nvim_win_set_width background width)
  (vim.api.nvim_win_set_height background height)
  (vim.api.nvim_win_set_config present.window
                               {:col (math.floor (/ (- width slide-width) 2))
                                :height slide-height
                                :relative :editor
                                :row (math.floor (/ (- height slide-height) 2))
                                :width slide-width}))

(fn present.close []
  (vim.api.nvim_clear_autocmds {:group present.group})
  (vim.api.nvim_win_close present.window true)
  (vim.api.nvim_win_close background true)
  (vim.api.nvim_buf_delete present.buffer {:force true})
  (vim.api.nvim_buf_delete empty-buffer {:force true}))

present
