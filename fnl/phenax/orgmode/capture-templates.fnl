(local M {})

(fn M.capture_templates [notes-path]
  {:N {:description :Blackhole
       :target (vim.fs.joinpath notes-path :blackhole/logs.org)
       :template "* %T

** What happened?
-

** REAL consequence of that event
-

** Learnings and positive effects on you from that event
-

** Type \"This does not define me. This is a small stepping stone that I stumbled on. Get back up and keep walking.\". Do not copy paste please.


"}
   :P {:description "Personal project"
       :target (vim.fs.joinpath notes-path "projects/%^{Project name}.org")
       :template "* %? :project:

*** TODO
- [ ]

** Maybe

** Resources

** Notes

"}
   :W {:description "Work project"
       :target (vim.fs.joinpath notes-path "projects/work/%^{Project name}.org")
       :template "* %? :work:

*** TODO Planning
**** TODO ?
*** TODO ?

** Maybe

** Resources

** Notes

"}
   :d {:description :Daily
       :target (vim.fs.joinpath notes-path "daily/%<%Y-%m>.org")
       :template "* %<%Y-%m-%d> %<%A> :daily:

** What went well today?
- %?

** Grateful for?
-

** Positive emotions felt today + why
-

** Negative emotions felt today + why
-

** Challenges
-

** Stats [[+lua require 'phenax.orgmoderpg'.evaluateScore()][see current stats]]
#+begin_src lua
health_points(0)      -- physical condition
persistance(0)        -- habits, routine
money(0)              -- finances, stability
experience_points(0)  -- outdoors, life experience, growth, creative expression, hobbies
assist_points(0)      -- helping others, positive interactions, donations
social_points(0)      -- family, friends, romantic
essence(0)            -- mental health, sense of self
productivity(0)       -- goals accomplished, work, career, growth, leadership
#+end_src

** Goals for tomorrow (copy to sidekick)
-


-----

"}})

M
