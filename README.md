# Local Installation

## Setup instructions

### Step #1: Lando environment setup

**This is a one time setup - skip this if you already have a working Lando environment.**  

Follow [Lando environment setup instructions](https://docs.lando.dev/getting-started/installation.html)

### Step #2: Project setup

1. Clone this repo

    ```
   git@github.com:propeoplemd/ffw-ass-drupal.git
   cd ffw-ass-drupal
    ```

2. Run composer install

    ```
    lando composer install
    ```

2. Start the site

    ```
    lando start
    ```

3. Point your browser to one of these URLs. For example:

    ```
    ✔ APPSERVER URLS
      ✔ http://site1.lndo.site/ [200]
      ✔ https://site1.lndo.site/ [200]
      ✔ http://site2.lndo.site/ [200]
      ✔ https://site2.lndo.site/ [200]
      ✔ http://site3.lndo.site/ [200]
      ✔ https://site3.lndo.site/ [200]
    ```

   For the list of local drush aliases look into drush/site/self.site.yml file.

4. Get Drush site aliaes: 
    ```
    lando drush sa
    ```

5. Import database for each site:
    ```
    lando drush @site.alias sqlc < db_name.sql
    ```

## Static site generation

1. From UI
- Go to */admin/config/tome/static/generate*
- Fill in the base URL and click **Submit** to generate
- Go to */admin/config/tome/static/preview* to preview the generated static site

2. Using CLI
- Execute `lando drush -l my.domain.com tome:static`

## More automation with bash script

New site provisioning can be automated executing `init-site.sh` script
This script receive two arguments:

  ```
  sh init-site.sh <sitename> <langcode>

  <sitename>: Name of new site in lowercase. Default: "new-site"
  <langoce>: Site language (e.g: fr, uk, vi,...). Default: "en"
  ```
