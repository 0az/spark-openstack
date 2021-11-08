#! /bin/bash

sudo mysql keystone <<EOF
START transaction;
UPDATE keystone.endpoint
	SET url = replace(url, 'http://ctl:', 'http://ctl.afzhou-110023.orion-pg0.utah.cloudlab.us:')
	WHERE interface = 'public'
;
SELECT id, url
	FROM keystone.endpoint
	WHERE interface = 'public'
;
COMMIT;
EOF
sudo service memcached restart
