#!/bin/bash
# Beware - if you have a custom WP TABLE_PREFIX remember to change `wp_options` for `wp_prefix_options`
mysql -u wp_user -pwp_pass -D wp_wordpress <<EOF
UPDATE wp_options 
SET option_value = "http://localhost:8000"
WHERE option_name = "siteurl";

UPDATE wp_options 
SET option_value = "http://localhost:8000"
WHERE option_name = "home";
EOF