#!/usr/bin/env bash

# Abort if anything fails
set -e

#-------------------------- Settings --------------------------------

if [[ $# -eq 0 ]]; then
  NEW_SITE_NAME="new-site"
else
  NEW_SITE_NAME=$1
fi
if [[ $# -eq 2 ]]; then
  NEW_SITE_LOCALE=$2
else
  NEW_SITE_LOCALE="en"
fi
NEW_SITEDIR_PATH="web/sites/$NEW_SITE_NAME"
NEW_SITE_SERVICE_RECORD="  $NEW_SITE_NAME:\n    type: mysql:5.7\n    creds:\n      user: user\n      password: user\n      database: $NEW_SITE_NAME\n"
NEW_SITE_APPSERVER="$NEW_SITE_NAME.lndo.site"
DRUSH_ALIAS_PATH="drush/sites"
DEFAULT_SITEDIR_PATH="web/sites/default"
SITES_PATH="web/sites"

#-------------------------- END: Settings --------------------------------

#-------------------------- Helper functions --------------------------------

# Console colors
red='\033[0;31m'
green='\033[0;32m'
green_bg='\033[1;97;42m'
yellow='\033[1;33m'
NC='\033[0m'

# echo-red() { echo -e "${red}$1${NC}"; }
echo_green() { echo "${green}$1${NC}"; }
# echo_green-bg() { echo -e "${green_bg}$1${NC}"; }
echo_yellow() { echo "${yellow}$1${NC}"; }

# Copy a settings file.
# Skips if the destination file already exists.
# @param $1 source file
# @param $2 destination file
copy_settings_file() {
  local source="$1"
  local dest="$2"

  if [[ ! -f $dest ]]; then
    echo "Copying ${dest}..."
    cp $source $dest
  else
    echo "${dest} already in place."
  fi
}

create_new_site_dir() {
  echo_green "Creating new site directory..."
  mkdir $SITES_PATH/$NEW_SITE_NAME
}

file_ends_with_newline() {
  [[ $(tail -c1 "$1" | wc -l) -gt 0 ]]
}

# Add lando config for new site.
add_lando_config() {
  echo_green "Adding lando config for new site..."
  sed -i '' "s/#end-proxy/    - $NEW_SITE_APPSERVER\n&/" .lando.yml
  sed -i '' "s/#end-services/$NEW_SITE_SERVICE_RECORD&/" .lando.yml
}

add_new_site_record() {
  echo_green "Adding new site record..."
  echo "\$sites['$NEW_SITE_NAME.lndo.site'] = '$NEW_SITE_NAME';" >>$SITES_PATH/sites.php
}

add_new_site_drush_alias() {
  echo_green "Adding new site drush alias..."
  if file_ends_with_newline $DRUSH_ALIAS_PATH/self.site.yml; then
    echo "$NEW_SITE_NAME:
 root: /app/web
 uri: http://$NEW_SITE_NAME.lndo.site" >>$DRUSH_ALIAS_PATH/self.site.yml
  else
    echo "\n$NEW_SITE_NAME:
 root: /app/web
 uri: http://$NEW_SITE_NAME.lndo.site" >>$DRUSH_ALIAS_PATH/self.site.yml
  fi
}

# Initialize local settings files
init_settings() {
  # Copy from settings templates
  copy_settings_file "$DEFAULT_SITEDIR_PATH/default.settings.php" "$NEW_SITEDIR_PATH/settings.php"
  add_lando_config
  add_new_site_record
  add_new_site_drush_alias
}

# Fix file/folder permissions
fix_permissions() {
  echo_green "Making new site directory writable..."
  chmod 755 "$NEW_SITEDIR_PATH"
}

# Install site
site_install() {
  cd web
  # lando rebuild -y

  echo_green "Installing new site..."
  lando drush @self.$NEW_SITE_NAME site:install --db-url=mysql://user:user@$NEW_SITE_NAME/$NEW_SITE_NAME --site-name=$NEW_SITE_NAME --locale=$NEW_SITE_LOCALE -y
}

#-------------------------- END: Helper functions --------------------------------

#-------------------------- Execution --------------------------------

# Project initialization steps

# create_new_site_dir
# fix_permissions
# init_settings
time -p site_install

echo_green "Settings configuration sync directory..."
cd ../
sed -i '' "s#sites/$NEW_SITE_NAME/files/config.*\'#../config/sync'#" $NEW_SITEDIR_PATH/settings.php
echo_green "Done!"

echo "Open ${yellow}http://${NEW_SITE_NAME}.lndo.site${NC} in your browser to verify the setup."
echo_yellow "Look for admin login credentials in the output above."

#-------------------------- END: Execution --------------------------------
