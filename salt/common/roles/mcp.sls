#!yaml
#init.sls for role-mcp

include:
    - saltmine.pkgs.boto
    - saltmine.states.cron.cron-logging
    - common.states.cron.live-instances
    - common.states.cron.overstate
