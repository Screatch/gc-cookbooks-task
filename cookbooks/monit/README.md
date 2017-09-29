# monit cookbook

## Usage
  * In order to install and start monit run **monit::default**
  * To create nginx monitrc run **monit::nginx**
  * To create unicorn, sidekiq monitrc for each available application, run **monit::unicorn, monit::sidekiq**
  * To create a new custom monitrc for some service, create template, create recipe with predefined defitional command to easily create monitrc config. Refer to **monit::nginx** for example

## Recipes
  * **default**
    * Installs monit package
    * Enables on boot and starts monit server
  * **nginx**
    * Creates monit config for Nginx
  * **sidekiq**
    * For each available application creates "sidekiq_appname" monit config
  * **unicorn**
    * For each available application creates "unicorn_appname" monit config

## Attributes
  * `node['monit']['nginx']['pid']` - Nginx pid location used in nginx recipe
  * `node['monit']['nginx']['group']` - Nginx group used in nginx recipe
  **Deploy cookbook attributes, refer to cookbok for full description**
  * `node['deploy_path']`

## Data bags attributes
  * "aws_opsworks_app"
    * `app['shortname']` - App name

## Templates
  * nginx.monitrc
  * sidekiq.monitrc - Group is set to deployment
  * unicorn.monitrc - Group is set to deployment

