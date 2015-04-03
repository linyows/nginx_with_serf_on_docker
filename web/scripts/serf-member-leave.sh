if [ "x${SERF_SELF_ROLE}" != "xlb" ]; then
    echo "Not an lb. Ignoring member leave"
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

    IP=$(echo $line | awk '{print $2 }')
    sed -i "/${IP} weight=${weight};/d" /etc/nginx/sites-enabled/default
    sed -i "/${IP} weight=${weight};/d" /var/log/supervisor/nginx-available-servers.txt
done

service nginx reload
