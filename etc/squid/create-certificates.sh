CRT_DIR='/etc/squid/certificates'

mkdir -p ${CRT_DIR}
openssl req -x509 -sha256 -new -newkey rsa:4096 -keyout ${CRT_DIR}/ca.key -out ${CRT_DIR}/ca.crt -days 365 -nodes -subj '/O=Recipe Radar (development)'
