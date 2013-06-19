#!mako|yaml

include:
  - saltmine.pkgs.crontab
  - saltmine.states.cron.cron-defaults
  - saltmine.pkgs.curl

#sync-s3-war.sls
<%
environment=grains['environment']
salt_basedir = pillar['salt_basedir']
saltmine_crontab_file_root=pillar['saltmine_crontab_file_root']
pull_tarball_times = pillar['cron']['nodejs']['pull']

node = pillar['node']
if node:
  node_bundle = pillar['node_bundle']
  node_salt_file = "%s/%s/%s" % (salt_basedir, node['salt_bundle_dir'], node_bundle)
%>
## SYNC WAR FILE

% if environment == 'testing' == node:
<%
  node_artifact  = "%s/%s"    % (node['base_url'], node_bundle)
  curl_cmd = "/usr/bin/curl -z %s %s %s -o %s" % (node_salt_file, node['curl_auth'], node_artifact, node_salt_file)
%>
sync-artifactory-node-cron-accumulate:
  file.accumulated:
    - name: mycrontab
    - filename: ${saltmine_crontab_file_root}
    - text: |
        ${pull_tarball_times} ${curl_cmd} >> /var/log/cron.log 2>&1
    - require_in: 
      - file: crontab-file
    - require:
      - pkg: curl-pkg
% endif