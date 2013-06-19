#!mako|yaml

<%
current_dir = 'common.roles.nodejs'
%>

include:
  - $current_dir+'.deploy-config'
  - $current_dir+'.deploy-app'

#extend:
  
