#!mako|yaml

include:
  - saltmine.pkgs.crontab
  - saltmine.states.cron.cron-defaults
  - saltmine.pkgs.s3cmd

<%

environment     = grains['environment']
s3nodejs_bucket = pillar['s3nodejs_bucket']
salt_basedir    = pillar['salt_basedir']
node_basedir    = pillar['node_basedir']
saltmine_crontab_file_root = pillar['saltmine_crontab_file_root']
pull_tarball_times = pillar['cron']['nodejs']['pull']

%>

sync-nodejs-cron-accumulate:
  file.accumulated:
    - name: mycrontab
    - filename: ${saltmine_crontab_file_root}
    - text: |
        ${pull_tarball_times} s3cmd sync ${s3nodejs_bucket} ${salt_basedir}/${node_basedir} >> /var/log/cron.s3nodejs.log 2>&1
    - require_in: 
      - file: crontab-file
    - require:
      - pkg: s3cmd-pkg
