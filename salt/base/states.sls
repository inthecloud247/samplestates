#!mako|yaml

#base states init.sls

include:
  - saltmine.states.motd
  - saltmine.states.htop.htop-user
  - saltmine.states.hostname