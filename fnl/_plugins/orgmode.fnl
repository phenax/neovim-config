(local colors (require :_settings.colors))
(local orgmode (require :orgmode))
(local orgconfig (require :phenax.orgmode.config))
(local orgcapture-templates (require :phenax.orgmode.capture-templates))

(local m {})
(local plugin {:config (fn [] (m.config))})

(fn m.config []
  (orgmode.setup {:calendar_week_start_day 0
                  :mappings (m.keybinds)
                  :org_agenda_files (vim.fs.joinpath orgconfig.path :**/*.org)
                  :org_agenda_start_on_weekday 0
                  :org_capture_templates (orgcapture-templates.capture_templates orgconfig.path)
                  :org_deadline_warning_days 7
                  :org_default_notes_file orgconfig.notes_entry_file
                  :org_hide_leading_stars true
                  :org_startup_indented true
                  :org_todo_keyword_faces {:ACTIVE (.. ":foreground "
                                                       (. colors.yellow 200))
                                           :BLOCKED ":foreground gray"
                                           :CANCELLED ":foreground gray"}
                  :org_todo_keywords [:TODO :ACTIVE "|" :DONE :BLOCKED]
                  :win_split_mode :25split})
  ;; Filetype config
  (vim.api.nvim_create_autocmd :FileType
                               {:callback (fn [] (m.configure_org_ft))
                                :pattern [:org :orgagenda]})
  ;; Personal plugins
  ((. (require :phenax.orgmode.links) :initialize))
  ((. (require :phenax.orgmode.present) :initialize)))

(fn m.configure_org_ft []
  (set vim.opt_local.conceallevel 2))

(fn m.keybinds []
  {:agenda {:org_agenda_earlier :H
            :org_agenda_goto :<CR>
            :org_agenda_goto_date :J
            :org_agenda_goto_today "."
            :org_agenda_later :L
            :org_agenda_switch_to :<C-Tab>}
   :global {:org_agenda :<leader>oa :org_capture :<leader>oc}
   :org {:org_backward_heading_same_level "[{"
         :org_change_date :cid
         :org_clock_cancel :<leader>cx
         :org_clock_in :<leader>ci
         :org_clock_out :<leader>co
         :org_cycle :<leader>zza
         :org_deadline :<localleader>id
         :org_forward_heading_same_level "]}"
         :org_global_cycle :<leader>zzg
         :org_insert_todo_heading_respect_content :<localleader>tn
         :org_next_visible_heading "]]"
         :org_open_at_point :<M-o>
         :org_previous_visible_heading "[["
         :org_schedule :<localleader>is
         :org_todo :<localleader>tt
         :org_toggle_checkbox :<localleader>cc}})

plugin
