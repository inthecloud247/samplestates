#!mako|yaml

# overstate api servers on cron

include:
  - saltmine.pkgs.crontab
  - saltmine.states.cron.cron-defaults

<%
environment=grains['environment']
saltmine_crontab_file_root=pillar['saltmine_crontab_file_root']
overstate_config=pillar['overstate_config']
%>

## highstate the roles
## TODO parameterize the named groups

% for role in [ 'api' ]:
overstate-${role}-cron-accumulate:
  file.accumulated:
    - name: mycrontab
    - filename: ${saltmine_crontab_file_root}
    - text: |
        ${overstate_config['cron'][role]} salt-run state.over base /srv/cloudconf/salt/overstate.sls >> /var/log/cron.overstate.log 2>&1
    - require_in: 
      - file: crontab-file
% endfor