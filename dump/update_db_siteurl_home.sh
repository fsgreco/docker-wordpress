#!/bin/bash
mysql -u wp_user -pwp_pass -D wp_wordpress <<EOF
UPDATE wp_options 
SET option_value = "http://localhost:8000"
WHERE option_name = "siteurl";

UPDATE wp_options 
SET option_value = "http://localhost:8000"
WHERE option_name = "home";
EOF