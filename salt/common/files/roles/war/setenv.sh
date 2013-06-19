umask 002
export CATALINA_OPTS="-Xmx8g -Dcom.sun.management.jmxremote \
        -Dcom.sun.management.jmxremote.port=7199 \
        -Dcom.sun.management.jmxremote.ssl=false \
        -Dcom.sun.management.jmxremote.authenticate=false \
        -Dcom.sun.management.jmxremote.password.file=/var/lib/tomcat7/conf/jmxremote.password \
        -Dcom.sun.management.jmxremote.accessfile=/var/lib/tomcat7/conf/jmxremote.access"
