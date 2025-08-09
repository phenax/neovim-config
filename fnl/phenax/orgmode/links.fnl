(import-macros {: key! : aucmd! : augroup!} :phenax.macros)
(local {: present? : not_nil?} (require :phenax.utils.utils))
(local {: nil? : string?} (require :nfnl.core))
(local orgmode (require :orgmode))
(local orgmode-api (require :orgmode.api))

(local orglinks {})

(fn orglinks.initialize []
  (aucmd! :FileType {:callback (fn [] (orglinks.setup_current_buf))
                     :group (augroup! :phenax/orgmode_links {:clear true})
                     :pattern :org}))

(fn orglinks.setup_current_buf []
  (key! :n :<Tab> (fn [] (orglinks.jump_to_next_link)) {:buffer true})
  (key! :n :<S-Tab> (fn [] (orglinks.jump_to_previous_link)) {:buffer true})
  (key! :n :<CR> (fn [] (orglinks.open_at_cursor)) {:buffer true})
  (key! :n :<M-e> (fn [] (orglinks.execute_block_under_cursor)) {:buffer true})
  (key! :n :gx (fn [] (orglinks.open_at_cursor_ext)) {:buffer true})
  (key! :n :<leader>gi (fn [] (orglinks.openAtCursorImage)) {:buffer true}))

(fn orglinks.open_at_cursor_ext []
  (local cursor-link (orglinks.link_under_cursor))
  (when (and cursor-link cursor-link.url)
    (local full-path (or (cursor-link.url:get_real_path)
                         (cursor-link.url:get_file_path)))
    (when (present? full-path) (vim.ui.open full-path))))

(fn orglinks.command_link? [link]
  (and link link.url (not_nil? (link.url.url:find "^+"))))

(fn orglinks.run_command_link [link]
  (local cmd (link.url.url:sub 2))
  (print (.. "Running: " cmd))
  (vim.cmd cmd))

(fn orglinks.open_at_cursor []
  (local link (orglinks.link_under_cursor))
  (if (orglinks.command_link? link) (orglinks.run_command_link link)
      (orgmode.action :org_mappings.open_at_point)))

(fn orglinks.jump_to_next_link []
  (orglinks.jump_to_link orglinks.next_link))

(fn orglinks.jump_to_previous_link []
  (orglinks.jump_to_link orglinks.previous_link))

(fn orglinks.next_link [links cursor]
  (local links-before-cursor
         (vim.tbl_filter (fn [link]
                           (let [rowdist (- link.range.start_line (. cursor 1))
                                 coldist (- link.range.start_col (. cursor 2))]
                             (or (> rowdist 0)
                                 (and (= rowdist 0) (> coldist 0)))))
                         links))
  (orglinks.get_closest_link_to_cursor links-before-cursor cursor))

(fn orglinks.previous_link [links cursor]
  (local links-before-cursor
         (vim.tbl_filter (fn [link]
                           (let [rowdist (- link.range.start_line (. cursor 1))
                                 coldist (- link.range.start_col (. cursor 2))]
                             (or (< rowdist 0)
                                 (and (= rowdist 0) (< coldist 0)))))
                         links))
  (orglinks.get_closest_link_to_cursor links-before-cursor cursor))

(fn orglinks.jump_to_link [get-link]
  (let [links (orglinks.get_doc_links)
        win-id (vim.api.nvim_get_current_win)
        cursor (vim.api.nvim_win_get_cursor win-id)
        link (get-link links cursor)]
    (when (not_nil? link)
      (vim.api.nvim_win_set_cursor win-id
                                   [link.range.start_line link.range.start_col]))))

(fn orglinks.execute_block_under_cursor []
  (local blocks (: (. (orgmode-api:current) :_file) :get_blocks))
  (each [_ block (ipairs blocks)]
    (local (start-row _ end-row _) (block.node:range false))
    (local row (. (vim.api.nvim_win_get_cursor 0) 1))
    (when (and (<= start-row row) (>= end-row row))
      (local lang (or (block:get_language) :lua))
      (local eval (. orglinks.evaluator lang))
      (when (nil? eval) (error (.. "No evaluator for " lang)))
      (local code (table.concat (block:get_content) "\n"))
      (eval code (fn [d] (print d))))))

;; fnlfmt: skip
(fn clean_output [cb]
  (fn [_ data]
    (if (not_nil? data) nil
        (string? data)) (cb (data:gsub "%s+$" ""))
        (cb data)))

(set orglinks.evaluator
     {:bash (fn [code on-result]
              (vim.system [:bash :-c code]
                          {:stderr (clean_output on-result)
                           :stdout (clean_output on-result)
                           :text true}))
      :javascript (fn [code on-result]
                    (vim.system [:node :-e code]
                                {:stderr (clean_output on-result)
                                 :stdout (clean_output on-result)
                                 :text true}))
      :lua (fn [code on-result]
             (on-result ((load code))))})

(fn orglinks.link_under_cursor []
  (local links (orglinks.get_doc_links))
  (when (not_nil? (. links 1))
    (: (. links 1) :at_cursor)))

(fn orglinks.get_doc_links []
  (local file (orgmode-api.current))
  (file._file:get_links))

(fn orglinks.get_closest_link_to_cursor [links cursor]
  (var closest-dist math.huge)
  (var closest-link nil)
  (each [_ link (ipairs links)]
    (local distance (orglinks.cursor_distance [link.range.start_line
                                               link.range.start_col]
                                              cursor))
    (when (< distance closest-dist) (set closest-dist distance)
      (set closest-link link)))
  closest-link)

(fn orglinks.cursor_distance [a b]
  (when (= (. a 1) (. b 1))
    (let [___antifnl_rtns_1___ [(math.abs (- (. b 2) (. a 2)))]]
      (lua "return (table.unpack or _G.unpack)(___antifnl_rtns_1___)")))
  (* 2 (math.abs (- (. b 1) (. a 1)))))

(fn _G._OpenImage [path]
  (vim.cmd (.. "!feh -x -F --image-bg \"#0f0c19\" " path)))

orglinks
