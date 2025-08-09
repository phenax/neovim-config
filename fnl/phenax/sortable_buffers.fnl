(import-macros {: key! : cmd! : aucmd! : augroup!} :phenax.macros)
(local {: present? : not_nil? : clamp : ++} (require :phenax.utils.utils))
(local core (require :nfnl.core))
(local snacks_picker_actions (require :snacks.picker.actions))

(local sortable-buffers {:actions {}
                         :config {:short_name_columns 45}
                         :sorted_buffers {}})

(fn sortable-buffers.initialize []
  (key! :n :<localleader>b (fn [] (sortable-buffers.buffer_picker)))
  (key! :n "]b" (fn [] (sortable-buffers.select_buffer core.inc)))
  (key! :n "[b" (fn [] (sortable-buffers.select_buffer core.dec)))
  ;; <localleader>1-0 keys map to 1-10
  (for [i 1 10]
    (local key (if (= i 10) 0 i))
    (key! :n (.. :<localleader> key) (fn [] (sortable-buffers.select_buffer i))))
  ;; Update buffer list on buf events
  (local group (augroup! :phenax/sortable_buffers {:clear true}))
  (aucmd! [:BufAdd :BufDelete :BufHidden :BufUnload]
          {:callback (fn [] (sortable-buffers.populate_buffers)) : group}))

(fn sortable-buffers.mappings []
  (lambda last-index [] (length sortable-buffers.sorted_buffers))
  (lambda first-index [] 1)
  {:<c-d> (++ [sortable-buffers.actions.delete_buffer] {:mode [:i :n]})
   :dd (++ [sortable-buffers.actions.delete_buffer] {:mode :n})
   :<c-g>g (++ [(sortable-buffers.actions.move_buffer first-index)]
               {:mode [:i :n] :nowait true})
   :<c-g>G (++ [(sortable-buffers.actions.move_buffer last-index)]
               {:mode [:i :n] :nowait true})
   :<c-j> (++ [(sortable-buffers.actions.move_buffer core.inc)] {:mode [:i :n]})
   :<c-k> (++ [(sortable-buffers.actions.move_buffer core.dec)] {:mode [:i :n]})
   :dd (++ [sortable-buffers.actions.delete_buffer] {:mode :n})})

(fn sortable-buffers.buffer_picker []
  (sortable-buffers.populate_buffers)
  (local current-buffer (vim.api.nvim_get_current_buf))
  (Snacks.picker.pick {:finder sortable-buffers.finder
                       :focus :list
                       :format sortable-buffers.formatter
                       :on_show (fn [picker]
                                  (local cur
                                         (sortable-buffers.buffer_to_sort_position current-buffer))
                                  (sortable-buffers.set_selection picker cur))
                       :preview (. (require :snacks.picker) :preview :file)
                       :source :sortable_buffers
                       :title :Buffers
                       :win {:input {:keys (sortable-buffers.mappings)}
                             :list {:keys (sortable-buffers.mappings)}}}))

(fn sortable-buffers.finder []
  (fn to-finder-result [[index buf]]
    (local info (. (vim.fn.getbufinfo buf) 1))
    (local file (if (present? info.name) info.name nil))
    (local bufname (or (and file (vim.fn.fnamemodify file ":~:.")) "[No Name]"))
    {: buf :changed (= info.changed 1) :file bufname : index :text bufname})

  (core.map-indexed to-finder-result sortable-buffers.sorted_buffers))

(fn sortable-buffers.formatter [entry]
  (local segments (vim.split entry.file "/"))
  (var file-short (. segments (length segments)))
  (when (> (length segments) 1)
    (set file-short (.. (. segments (- (length segments) 1)) "/"
                        (. segments (length segments)))))
  (when (> (string.len file-short) sortable-buffers.config.short_name_columns)
    (set file-short (.. "…" (string.sub file-short
                                          (+ (- sortable-buffers.config.short_name_columns)
                                             2)
                                          (- 1)))))
  (local align Snacks.picker.util.align)
  [[(align (tostring entry.index) 4) :PhenaxBufferIndex]
   [(align file-short sortable-buffers.config.short_name_columns)
    :PhenaxBufferShortName]
   [entry.text (if entry.changed :PhenaxBufferNameChanged :PhenaxBufferName)]])

(fn sortable-buffers.select_buffer [pos]
  (sortable-buffers.populate_buffers)
  (when (core.function? pos)
    (local cur
           (sortable-buffers.buffer_to_sort_position (vim.api.nvim_get_current_buf)))
    (set-forcibly! pos (pos cur))
    (when (> pos (length sortable-buffers.sorted_buffers))
      (set-forcibly! pos 1))
    (when (< pos 1)
      (set-forcibly! pos (length sortable-buffers.sorted_buffers))))
  (local buf (. sortable-buffers.sorted_buffers pos))
  (when (= buf nil) (lua "return "))
  (vim.api.nvim_set_current_buf buf))

;; TODO: Refactor
(fn sortable-buffers.buffer_to_sort_position [buf]
  (each [index value (ipairs sortable-buffers.sorted_buffers)]
    (when (= buf value) (lua "return index")))
  (length sortable-buffers.sorted_buffers))

;; TODO: Refactor
(fn sortable-buffers.actions.move_buffer [get-new-index]
  (fn move-buf [cur-index next-index]
    (when (or (< cur-index 1)
              (> cur-index (length sortable-buffers.sorted_buffers)))
      (lua "return "))
    (when (or (< next-index 1)
              (> next-index (length sortable-buffers.sorted_buffers)))
      (lua "return "))
    (local buf (. sortable-buffers.sorted_buffers cur-index))
    (table.remove sortable-buffers.sorted_buffers cur-index)
    (table.insert sortable-buffers.sorted_buffers next-index buf))

  (fn []
    (let [picker (sortable-buffers.get_current_picker)
          pos picker.list.cursor
          entry (picker.list:current)]
      (when (not entry) (lua "return "))
      (local cur-index (sortable-buffers.buffer_to_sort_position entry.buf))
      (local is-filtered (not= pos cur-index))
      (local next-index (get-new-index cur-index))
      (move-buf cur-index
                (clamp next-index 1 (length sortable-buffers.sorted_buffers)))
      (sortable-buffers.refresh_picker)
      (if (not is-filtered)
          (sortable-buffers.set_selection picker next-index)
          (sortable-buffers.set_selection picker pos)))))

(fn sortable-buffers.actions.delete_buffer []
  (local picker (sortable-buffers.get_current_picker))
  (when (not picker) (lua "return "))
  (local entry (picker.list:current))
  (when (not entry) (lua "return "))
  (var pos picker.list.cursor) ; Store position before deleting
  (snacks_picker_actions.bufdelete picker)
  (sortable-buffers.populate_buffers)
  (sortable-buffers.refresh_picker)
  (set pos (math.min pos (picker.list:count)))
  (sortable-buffers.set_selection picker pos))

(fn sortable-buffers.set_selection [picker pos] (picker.list:view pos))

(fn sortable-buffers.get_current_picker [] (. (Snacks.picker.get) 1))

(fn sortable-buffers.refresh_picker []
  (local picker (sortable-buffers.get_current_picker))
  (when (not_nil? picker)
    (picker:find {:refresh true})))

(fn sortable-buffers.populate_buffers []
  (set sortable-buffers.sorted_buffers
       (vim.tbl_filter sortable-buffers.is_buf_valid
                       sortable-buffers.sorted_buffers))
  ;; Check for new buffers
  (local bufnrs (vim.api.nvim_list_bufs))
  (each [_ buf (ipairs bufnrs)]
    (local new_valid_buf?
           (and (sortable-buffers.is_buf_valid buf)
                (not (vim.tbl_contains sortable-buffers.sorted_buffers buf))))
    (when new_valid_buf? (table.insert sortable-buffers.sorted_buffers buf))))

(fn sortable-buffers.is_buf_valid [buf]
  (and (vim.api.nvim_buf_is_valid buf) (= (vim.fn.buflisted buf) 1)))

sortable-buffers
