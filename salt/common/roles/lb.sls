#!mako|yaml

<%
  environment = grains['environment']
  group = grains['group'] if 'group' in grains else None

  server_status = pillar['server_status']
  bauth         = pillar['haproxy_basic_auth']
  backend_static_servers = pillar['backend_static_servers']
%>

include:
  - saltmine.states.haproxy
  - saltmine.states.haproxy.haproxy-rsyslog

extend:
  haproxy-service:
    service:
      - running
      - enable: True

  haproxy-cfg:
    file.managed:
      - source: salt://common/files/roles/lb/haproxy.cfg.mako
      - template: mako
      - require:
        - pkg: haproxy-pkg
      - defaults:
          stats_enable:   'enable'
          stats_login:    '${pillar[stats_login]}'
          stats_password: '${pillar[stats_password]}'

  % if bauth:
          user_lists:
            ${bauth['user_list']}:
  <% users = bauth['users'] %>
  % for user in users:
              ${user}: ${users[user]}
  % endfor
  % endif

          frontend:
            - 'acl api_request url_beg /api'
            - 'use_backend backend-api-1 if api_request'
            - 'acl auth_request url_beg /frontdoor'
            - 'use_backend backend-auth if auth_request'
            - 'acl static_request url_beg /static'
            - 'use_backend backend-s3 if static_request'
            - 'default_backend             backend-nodejs'

          backends:
            # backend-s3
            - name: backend-s3
              server_port: '80'
              options:
                - 'reqdel ^Host.*'
  % for server in backend_static_servers:
  <% srv=backend_static_servers[server] %>
                - |
                  reqadd Host:\ ${srv['dns']}
  % endfor
                - 'option httpchk GET /'
  # TODO Jeremy says do layer3, not layer7
              server_options: 'weight 1 check port 80 observe layer7'

              servers:
  % for server in backend_static_servers:
  <% srv=backend_static_servers[server] %>
                - name: ${srv['name']}
                  dns:  ${srv['dns']}
  % endfor

            # backend-nodejs
            - name: backend-nodejs
              server_port: '3000'
              options:
                - 'balance     leastconn'
                - 'option httpchk GET /'
  % if bauth:
                - |
                  acl ${bauth['acl']} http_auth(${bauth['user_list']})
                  http-request auth realm ${bauth['realm']} if !${bauth['acl']}
  % endif

              server_options: 'weight 1 check port 3000 observe layer7'
            % if server_status:
              servers:
              % for server in server_status:
                  % if group == server_status[server]['group'] and server_status[server]['roles'] == 'nodejs' and server_status[server]['environment'] == environment and server_status[server]['state'] != 'TERMINATED':
                - name: ${server}
                  dns: ${server_status[server]['private_dns']}
                  % endif
              % endfor
            % endif

            # backend-api-1
            - name: backend-api-1
              server_port: '8080'
              options:
                - 'balance     leastconn'
                - 'option httpchk GET /api/health'
              server_options: 'weight 1 check port 8080 observe layer7'
            % if server_status:
              servers:
              % for server in server_status:
                  % if group == server_status[server]['group'] and server_status[server]['roles'] == 'api' and server_status[server]['environment'] == environment and server_status[server]['state'] != 'TERMINATED':
                - name: ${server}
                  dns: ${server_status[server]['private_dns']}
                  % endif
              % endfor
            % endif

            # backend-auth
            - name: backend-auth
              server_port: '8080'
              options:
                - 'balance     leastconn'
                - 'option httpchk GET /backend/health'
              server_options: 'weight 1 check port 8080 observe layer7'
            % if server_status:
              servers:
              % for server in server_status:
                  % if group == server_status[server]['group'] and server_status[server]['roles'] == 'auth' and server_status[server]['environment'] == environment and server_status[server]['state'] != 'TERMINATED':
                - name: ${server}
                  dns: ${server_status[server]['private_dns']}
                  % endif
              % endfor
            % endif