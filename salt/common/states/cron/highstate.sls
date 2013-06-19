#!mako|yaml

# highstate api servers on cron

include:
  - saltmine.pkgs.crontab
  - saltmine.states.cron.cron-defaults

<%
environment=grains['environment']
saltmine_crontab_file_root=pillar['saltmine_crontab_file_root']
cron=pillar['cron']
%>

## highstate the roles
## TODO parameterize the named groups

% for role in cron:
highstate-${role}-cron-accumulate:
  file.accumulated:
    - name: mycrontab
    - filename: ${saltmine_crontab_file_root}
    - text: |
        ${cron[role]['push']} salt --batch=1 -C 'G@environment:${environment} and G@group:beta and G@roles:${role}' state.highstate >> /var/log/cron.highstate-${role}.log 2>&1
    - require_in: 
      - file: crontab-file
% endfor
