#!mako|yaml
#init.sls for role-lb in group beta

# Cannot include the common since it defines keys that are not common to this lb
# include:
#   - common.roles.lb

<%
  environment = grains['environment']
  group = grains['group'] if 'group' in grains else None

  server_status = pillar['server_status']
  bauth         = pillar['haproxy_basic_auth']
  app_endpoint = pillar['war_customname'].split('.')[0]
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
          stats_login:    'test'
          stats_password: 'testmenow'

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
            - 'acl player2_request url_beg /player2'
            - 'use_backend backend-api-1 if api_request'
            - 'use_backend backend-static-1 if player2_request'
            - 'default_backend             backend-api-1'

          backends:
            # backend-api-1
            - name: backend-api-1
              server_port: '8080'
              options:
                - 'balance     leastconn'
                - 'option httpchk GET /${app_endpoint}/version'
              server_options: 'weight 1 check port 8080 observe layer7'
            % if server_status:
              servers:
              % for server in server_status:
                  % if group == server_status[server]['group'] and server_status[server]['roles'] == 'api' and server_status[server]['environment'] == environment:
                - name: ${server}
                  dns: ${server_status[server]['private_dns']}
                  % endif
              % endfor
            % endif

            # backend-api-1
            - name: backend-static-1
              server_port: '80'
              options:
                - 'reqrep ^([^\ ]*)\ /player2/(.*) \1\ /\2'
                - 'balance     leastconn'
                - 'option httpchk GET /robots.txt'
              server_options: 'weight 1 check port 80 observe layer7'
            % if server_status:
              servers:
              % for server in server_status:
                  % if group == server_status[server]['group'] and server_status[server]['roles'] == 'static' and server_status[server]['environment'] == environment:
                - name: ${server}
                  dns: ${server_status[server]['private_dns']}
                  % endif
              % endfor
            % endif