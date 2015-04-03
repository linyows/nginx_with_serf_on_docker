if [ "x${SERF_SELF_ROLE}" != "xlb" ]; then
    echo "Not an lb. Ignoring member join."
    exit 0
fi

while read line; do
    ROLE=`echo $line | awk '{print \$3 }'`
    if [ "x${ROLE}" != "xweb" ]; then
        continue
    fi

    if [ "x${ROLE}" == "xweb" ]; then
        weight=99
    elif [ "x${ROLE}" == "xweb_release" ]; then
        weight=1
    fi
    SERVER=`echo $line | awk '{printf "server %s weight=%s;", $2, $weight}'`

    sed -i "/upstream/a\  $SERVER" /etc/nginx/sites-enabled/default
    echo $SERVER >> /var/log/supervisor/nginx-available-servers.txt
done

service nginx start
service nginx reload
