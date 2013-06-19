#!mako|yaml
# node deployment

<%
environment=grains['environment']
user             = pillar['username']

# node = pillar['node']
# if node:
#   node_bundle      = pillar['node_bundle']  
#   node_salt_file   = "salt://%s/%s" % (pillar['node_basedir'], node_bundle)
#   node_server_file = "%s/%s"    % (node['server_bundle_dir'], node_bundle)
#   node_tmp_file    = "%s/%s"    % (bundle_tmpdir, node_bundle)
#   node_dir         = node['server_app_dir']
#   user             = pillar['username']
%>

# eventually maybe sync files from s3...
# salt-call s3.get net.vrsl.nodesites.prod pb-express-site-prod.tar.bz2 local_file=/tmp/pb-express-site-prod.tar.bz2

nodejs-${environment}-dot-config:
  file.managed:
    - source: 'salt://${environment}/files/groups/nodesites/.config.json'
    - name: /home/${user}/.config.json
    - user: ${user}
    - mode: 0600
    - template: mako
    - defaults:
        memcache_url:       ${pillar['node_memcache_url']}
        memcache_port:      ${pillar['node_memcache_port']}
        db_url:             ${pillar['node_db_url']}
        db_username:        ${pillar['node_db_user']}
        db_password:        ${pillar['node_db_pwd']}
        app_port:           ${pillar['node_app_port']}

nodejs-${environment}-express-conf:
  file.managed:
    - source: 'salt://${environment}/files/groups/nodesites/express.conf'
    - name: /etc/init/express.conf
    - user: root
    - mode: 0600
    - template: mako

<%
# mosquito-upstart-conf:
#   file.managed:
#     - name:   /etc/init/mosquito.conf
#     - source: 'salt://${environment}/files/roles/nodejs/mosquito.conf.mako'
#     - template: mako
#     - defaults:
#       user:     ${user}
#       node_dir: ${node_dir}
#       log: /var/log/mosquito.sys.log
#       pid: /var/run/mosquito.pid
%>