#---------------------------------------------------------------------
#   Amazing Automated Haproxy configuration
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    #log         127.0.0.1 local0
    log /dev/log local0 info
    log /dev/log local0 notice
    maxconn     60000
    ulimit-n 120015
    user        haproxy
    group       haproxy
    daemon

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode        http
    log         global
    option      dontlognull
    option      httpclose
    #option      http-server-close
    option      httplog
    option      forwardfor
    option      redispatch
    timeout connect 10000 # default 10 second time out if a backend is not found
    timeout client 300000
    timeout server 300000
    maxconn     60000
    retries     3
    stats ${ stats_enable }
    stats uri /lb?stats
    stats auth ${ stats_login }:${ stats_password }
    #option abortonclose 
    #option nolinger # disables data lingering
    option tcpka # enables keep-alive both on client and server side
    #option error-limit 3 # before being marked down (default is 10)
    #option rise 1 # (default is 2)
    #option fall 1 # how many unsuccessful checks before marked dead (default is three)

% if user_lists:
% for user_list in user_lists:
    userlist ${user_list}  <% users=user_lists[user_list] %>
%   for user in users:
      user ${user} insecure-password ${users[user]}
%   endfor
% endfor
% endif

frontend  frontend *:80
% for line in frontend:
    ${line}
% endfor

% for backend in backends:

backend ${backend['name']}
% if 'options' in backend:
  % for option in backend['options']:
    ${option}
  % endfor
% endif

% if backend['servers'] is not None:
  % for server in backend['servers']:
    server ${server['name']} ${server['dns']}:${backend['server_port']} ${backend['server_options']}
  % endfor
% endif

% endfor
