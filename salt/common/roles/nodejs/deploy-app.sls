#!mako|yaml
# node deployment

<%
environment      = grains['environment']
user             = pillar['username']

# salt_basedir = pillar['salt_basedir']
# saltmine_crontab_file_root=pillar['saltmine_crontab_file_root']

# bundle_tmpdir='/var/tmp'

# node = pillar['node']
# if node:
#   node_bundle      = pillar['node_bundle']  
#   node_salt_file   = "salt://%s/%s" % (pillar['node_basedir'], node_bundle)
#   node_server_file = "%s/%s"    % (node['server_bundle_dir'], node_bundle)
#   node_tmp_file    = "%s/%s"    % (bundle_tmpdir, node_bundle)
#   node_dir         = node['server_app_dir']


node_app_name = 'pb-express-site-prod.tar.bz2'
node_app_shortname = node_app_name.split('.')[0]

node_app_dir = '/home/ubuntu/pb-express-site-salt'
node_app_file = node_app_dir+'/'+node_app_name

node_tmp_dir = '/var/tmp'
node_tmp_file = node_tmp_dir+'/'+node_app_name

%>

get-${node_app_shortname}:
  file.managed:
    - name:    '${node_tmp_file}'
    - source:  'salt://${environment}/files/groups/nodesites/${node_app_name}'
    - user:    '${user}'
    - group:   '${user}'

deploy-${node_app_shortname}:
  cmd.wait:
    - name: |
        set -e
        service express status | grep running && service express stop
        rm -rf ${node_app_dir}
        mkdir -p ${node_app_dir} # TODO make it file.directory prereq
        cp -p ${node_tmp_file} ${node_app_file}
        tar -vjxf ${node_app_file} -C ${node_app_dir} --no-same-owner
        chown -R ${user}:${user} ${node_app_dir}
        service express start
    - shell: /bin/bash
    - unless: cmp ${node_tmp_file} ${node_app_file}
    - watch:
      - file: get-${node_app_shortname}
