#!mako|yaml

include:
  - saltmine.pkgs.crontab
  - saltmine.states.cron.cron-defaults


<%
environment=grains['environment']
saltmine_crontab_file_root=pillar['saltmine_crontab_file_root']
%>

## UPDATE DNS

update-dns-cron-accumulate:
  file.accumulated:
    - name: mycrontab
    - filename: ${saltmine_crontab_file_root}
    - text:
      - '*/4 * * * * python /root/update-dns.py --environment ${environment} --ensure /srv/cloudstate/pillar/${environment}/salt_cloud_live_instances.sls >> /var/log/cron.log 2>&1' 
    - require_in: 
      - file: crontab-file

update-dns-script:
  file.managed:
    - name: /root/update-dns.py
    - source: salt://update-dns.py
    - require_in:
      - file: update-dns-cron-accumulate

route53-script:
  file.managed:
    - name: /root/route53.py
    - source: salt://route53.py
    - require_in:
      - file: update-dns-cron-accumulate

mapper-script:
  file.managed:
    - name: /root/mapper.py
    - source: salt://mapper.py
    - require_in:
      - file: update-dns-cron-accumulate
