#!mako|yaml

include:
  - saltmine.pkgs.crontab
  - saltmine.states.cron.cron-defaults
  - saltmine.pkgs.s3cmd

#sync-s3-war.sls
<%
environment    = grains['environment']
s3war_bucket   = pillar['s3war_bucket']
salt_basedir   = pillar['salt_basedir']
war_basedir    = pillar['war_basedir']
saltmine_crontab_file_root=pillar['saltmine_crontab_file_root']
pull_war_times = pillar['cron']['api']['pull']
%>
## SYNC WAR FILE

sync-war-cron-accumulate:
  file.accumulated:
    - name: mycrontab
    - filename: ${saltmine_crontab_file_root}
    - text: |
        ${pull_war_times} s3cmd sync ${s3war_bucket} ${salt_basedir}/${war_basedir}/ >> /var/log/cron.log 2>&1
    - require_in: 
      - file: crontab-file
    - require:
      - pkg: s3cmd-pkg
