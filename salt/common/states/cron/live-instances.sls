#!mako|yaml

include:
  - saltmine.pkgs.crontab
  - saltmine.states.cron.cron-defaults

<%
environment=grains['environment']
saltmine_crontab_file_root=pillar['saltmine_crontab_file_root']
%>

## GET STATE OF CLOUD MACHINES

live-instances-cron-accumulate:
  file.accumulated:
    - name: mycrontab
    - filename: ${saltmine_crontab_file_root}
    - text:
      - '*/2 * * * * salt-cloud -Q --out=yaml | tee /srv/cloudstate/pillar/${environment}/salt_cloud_live_instances.sls >> /var/log/cron.log 2>&1'
    - require_in: 
      - file: crontab-file
