(import-macros {: aucmd!} :phenax.macros)
(local colors (require :_settings.colors))
(local theme {:colors (require :_settings.colors) :highlight {}})

(fn theme.setup [colorscheme]
  (set vim.o.background :dark)
  (set vim.g.base16colorspace 256)
  (set vim.go.termguicolors true)
  (aucmd! :ColorScheme
          {:callback theme.highlight_all
           :group (vim.api.nvim_create_augroup :phenax/theme {:clear true})})
  (vim.cmd.colorscheme colorscheme)
  (theme.setup_terminal_colors))

(fn theme.highlight.ui []
  (theme.update_hl {:ColorColumn {:bg (. colors.slate 200)}
                    :CurSearch {:bg (. colors.teal 800)
                                :fg (. colors.slate 300)
                                :bold true}
                    :CursorColumn {:bg (. colors.slate 200)}
                    :CursorLine {:bg (. colors.slate 200)}
                    :FloatBorder {:fg (. colors.accent 100)}
                    :Folded {:bg (. colors.bg 300) :fg (. colors.slate 600)}
                    :LineNr {:bg :none :fg (. colors.slate 500)}
                    :Normal {:bg :none :fg (. colors.slate 700)}
                    :NormalFloat {:bg (. colors.bg 200) :fg colors.white}
                    :NormalNC {:bg (. colors.bg 150)}
                    :Pmenu {:bg (. colors.slate 300) :fg (. colors.slate 600)}
                    :PmenuSel {:bg (. colors.accent 100) :fg colors.white}
                    :RulerFilePath {:bg (. colors.accent 100)
                                    :fg colors.white
                                    :bold true}
                    :RulerFileStatus {:bg (. colors.yellow 100)
                                      :fg (. colors.bg 100)
                                      :bold true}
                    :RulerFileType {:bg :none :fg colors.white :bold true}
                    :Search {:bg (. colors.slate 600)}
                    :SignColumn {:bg :none}
                    :StatusLine {:bg :none :fg (. colors.accent 100)}
                    :StatusLineNC {:bg :none :fg (. colors.slate 400)}
                    :VertSplit {:bg :none :fg (. colors.slate 400)}
                    :Whitespace {:fg (. colors.slate 400)}
                    :WinBar {:bg (. colors.bg 100) :fg (. colors.slate 600)}
                    :WinBarNC {:bg (. colors.bg 100) :fg (. colors.slate 400)}
                    :WinSeparator {:bg :none :fg (. colors.slate 400)}
                    :YankHighlight {:bg (. colors.slate 600)}
                    :netrwMarkFile {:bg (. colors.slate 500)
                                    :fg (. colors.slate 700)}}))

(fn theme.highlight.code []
  (theme.update_hl {"@markup.heading.1.markdown" {:bg (. colors.accent 200)
                                                  :bold true
                                                  :fg (. colors.slate 100)}
                    "@markup.heading.2.markdown" {:bg (. colors.green 500)
                                                  :bold true
                                                  :fg (. colors.slate 100)}
                    "@markup.link" {:fg (. colors.accent 200)}
                    "@markup.strong" {:bold true :fg (. colors.green 200)}
                    "@tag.attribute" {:fg (. colors.blue 200)}
                    "@tag.builtin" {:fg (. colors.blue 300)}
                    "@variable" {:fg colors.white}
                    "@variable.member" {:fg colors.white}
                    :Boolean {:fg (. colors.pink 100)}
                    :Comment {:fg (. colors.slate 500)}
                    :Constant {:link :String}
                    :Function {:fg (. colors.blue 100)}
                    :Keyword {:fg (. colors.teal 600)}
                    :Number {:fg (. colors.yellow 100)}
                    :Special {:fg (. colors.blue 300)}
                    :Statement {:fg (. colors.teal 700)}
                    :Tag {:fg (. colors.blue 100)}
                    :Todo {:bold true :fg (. colors.red 100)}
                    :Type {:fg (. colors.slate 700)}
                    "@punctuation.bracket.fennel" {:fg (. colors.slate 550)}
                    "@string.documentation.fennel" {:fg (. colors.slate 650)}}))

(fn theme.highlight.oil []
  (theme.update_hl {:OilDir {:fg (. colors.accent 200)}}))

(fn theme.highlight.fugitive []
  (theme.update_hl {:DiffAdd {:bg (. colors.green 600)}
                    :DiffChange {:bg (. colors.slate 500)}
                    :DiffDelete {:bg (. colors.red 400)}
                    :DiffText {:bg (. colors.slate 500)
                               :fg (. colors.green 700)
                               :bold true}
                    :diffAdded {:bg (. colors.green 600)}
                    :diffRemoved {:bg (. colors.red 400)}
                    :fugitiveHeading {:bold true}
                    :fugitiveStagedHeading {:fg (. colors.green 200)
                                            :bold true}
                    :fugitiveUnstagedHeading {:fg (. colors.yellow 200)
                                              :bold true}
                    :fugitiveUntrackedHeading {:fg (. colors.yellow 300)
                                               :bold true}}))

(fn theme.highlight.phenax_buffers []
  (theme.update_hl {:PhenaxBufferIndex {:link :Number}
                    :PhenaxBufferName {:fg (. colors.slate 800)}
                    :PhenaxBufferNameChanged {:bold true
                                              :fg (. colors.yellow 300)}
                    :PhenaxBufferShortName {:bold true :fg (. colors.teal 800)}}))

(fn theme.highlight.snacks_picker []
  (let [bg (. colors.bg 100)]
    (theme.update_hl {:SnacksPicker {: bg}
                      :SnacksPickerBorder {:bg :none :fg :none}
                      :SnacksPickerBoxTitle {:bg (. colors.accent 100)
                                             :fg colors.white}
                      :SnacksPickerCursorLine {:bg (. colors.slate 500)}
                      :SnacksPickerDir {:fg (. colors.slate 650)}
                      :SnacksPickerFile {:fg colors.white}
                      :SnacksPickerListCursorLine {:bg (. colors.slate 500)}
                      :SnacksPickerMatch {:fg (. colors.teal 800)}
                      :SnacksPickerPreviewCursorLine {:bg (. colors.slate 500)}})))

(fn theme.highlight.lsp []
  (let [lens-colors {:Error (. colors.red 500)
                     :Hint (. colors.violet 200)
                     :Info (. colors.green 100)
                     :Lens (. colors.violet 200)
                     :Warn (. colors.yellow 300)}]
    (theme.update_hl {:DiagnosticError {:fg lens-colors.Error}
                      :DiagnosticHint {:fg lens-colors.Hint}
                      :DiagnosticInfo {:fg lens-colors.Info}
                      :DiagnosticUnderlineError {:bold true
                                                 :fg lens-colors.Error
                                                 :underline true}
                      :DiagnosticUnderlineHint {:bold true
                                                :fg lens-colors.Hint
                                                :underline true}
                      :DiagnosticUnderlineInfo {:bold true
                                                :fg lens-colors.Info
                                                :underline true}
                      :DiagnosticUnderlineWarn {:bold true
                                                :fg lens-colors.Warn
                                                :underline true}
                      :DiagnosticWarn {:fg lens-colors.Warn}
                      :LspCodeLens {:fg lens-colors.Lens}
                      :LspInlayHint {:fg (. colors.slate 500)}
                      :LspReferenceText {:underline true}
                      :LspSignatureActiveParameter {:fg lens-colors.Info}})))

(fn theme.highlight.orgmode []
  (theme.update_hl {"@org.agenda.deadline" {:fg (. colors.red 200)}
                    "@org.agenda.scheduled" {:fg (. colors.green 500)}
                    "@org.agenda.scheduled_past" {:fg (. colors.yellow 300)}
                    "@org.agenda.today" {:bold true
                                         :fg (. colors.green 200)
                                         :underline true}
                    "@org.agenda.weekend" {:fg (. colors.slate 700)}
                    "@org.drawer" {:fg (. colors.slate 400)}
                    "@org.keyword.done" {:fg (. colors.green 400)}
                    "@org.keyword.todo" {:bold true :fg (. colors.red 200)}
                    "@org.plan" {:fg (. colors.slate 600)}
                    "@org.properties" {:fg (. colors.red 100)}
                    "@org.tag" {:fg (. colors.accent 100)}
                    "@org.timestamp.active" {:fg (. colors.accent 100)}}))

(fn theme.highlight_all []
  (each [_ value (pairs theme.highlight)] (value)))

(fn theme.update_hl [schemes]
  (each [k v (pairs schemes)] (vim.api.nvim_set_hl 0 k v)))

(fn theme.setup_terminal_colors []
  (set vim.g.terminal_color_0 (. colors.slate 200))
  (set vim.g.terminal_color_1 "#e06c75")
  (set vim.g.terminal_color_2 "#98C379")
  (set vim.g.terminal_color_3 "#E5C07B")
  (set vim.g.terminal_color_4 "#60a3bc")
  (set vim.g.terminal_color_5 "#4e3aA3")
  (set vim.g.terminal_color_6 "#56B6C2")
  (set vim.g.terminal_color_7 "#ABB2BF")
  (set vim.g.terminal_color_8 "#555555")
  (set vim.g.terminal_color_9 "#7c162e")
  (set vim.g.terminal_color_10 "#a3be8c")
  (set vim.g.terminal_color_11 "#f7b731")
  (set vim.g.terminal_color_12 "#5e81ac")
  (set vim.g.terminal_color_13 "#4e3aA3")
  (set vim.g.terminal_color_14 "#0fb9b1")
  (set vim.g.terminal_color_15 "#ebdbb2"))

theme
