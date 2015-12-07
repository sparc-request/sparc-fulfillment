Latest stable release v2.0.0

Work Fulfillment
=========================

# Customize the header background color and logos

1. Add institution specific CSS to /sparc-fulfillment/app/assets/stylesheets/customize.sass
2. Create a custom version of /sparc-fulfillment/app/views/application/_header.html.haml
3. Add the customized versions of app/assets/stylesheets/customize.sass and app/views/application/_header.html.haml to your server's /shared/ directory
4. Update your config/deploy.rb to include the two aforementioned files in the list of linked_files:
    set :linked_files, fetch(:linked_files, []).push('app/assets/stylesheets/customize.sass', 'app/views/application/_header.html.haml', 'config/database.yml', ....)
	
# Configure developer workstation to run both sparc-request and sparc-fulfillment

1. git clone https://github.com/sparc-request/sparc-fulfillment.git
2. rvm install ruby-2.1.5
3. rvm use ruby-2.1.5
4. bundle install
5. create local database for rails server:
  1. CREATE SCHEMA sparc_fulfillment; GRANT ALL ON sparc_fulfillment.* TO 'sparc'@'localhost';
6. create local test databases:
  1. CREATE SCHEMA test_sparc_fulfillment; GRANT ALL ON test_sparc_fulfillment.* TO 'sparc'@'localhost';
  2. CREATE SCHEMA test_sparc_request; GRANT ALL ON test_sparc_request.* TO 'sparc'@'localhost';
7. configure local databases named sparc_fulfillment, test_sparc_fulfillment, and test_sparc_request for development and test environments: 
  1. configure config/database.yml to connect to your dev and test databases
  2. configure config/shards.yml to connect to your dev and test sparc-request databases
  3. configure config/faye.xml 
  4. configure .env by copying from dotenv.example
8. run: rake db:migrate
9. run tests: bundle exec rspec
10. configure and start sparc-request on port 3000 with: 
  1. configure application.yml:
    1. remote_service_notifier_host: "127.0.0.1:5000"
    2. host: "127.0.0.1:3000"
    3. clinical_work_fulfillment_url: http://127.0.0.1:5000
  2. rails server
  3. bundle exec script/delayed_job start
  4. in catalog manager: turn on "Fulfillment" for an Institution, Provider, Program, or Core and give yourself "Fulfillment Provider Rights"
11. start sparc-fulfillment on port 5000 with: 
  1. rails server -p 5000
  2. bundle exec bin/delayed_job start
  3. thin -C config/faye.yml start
