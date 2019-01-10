[![Build Status](https://travis-ci.org/BathHacked/energy-sparks.svg?branch=master)](https://travis-ci.org/BathHacked/energy-sparks)
[![Maintainability](https://api.codeclimate.com/v1/badges/d71b5b77250c7b468c29/maintainability)](https://codeclimate.com/repos/5ae9d48381589502d00011c7/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/d71b5b77250c7b468c29/test_coverage)](https://codeclimate.com/repos/5ae9d48381589502d00011c7/test_coverage)




# Energy Sparks

Energy Sparks is an open source application that is designed to help schools improve their energy efficiency.

The application collects and presents gas and electricity usage data in a way that is accessible to staff, students and parents. Supported by educational resources, the application will support teachers in helping children understand more about energy usage, how to be more efficient and see how actions they take in the school, e.g. switching off lighting, has an effect on usage.

Combining access to data, the ability to log interventions and a competitive element between schools, the goal is to not just save schools money in reducing energy consumption through long term changes, it is hoped that the application will also help educate children about what it means to be energy efficient.

The application is open source and is powered by open data. It is being designed to be easily deploy and run for minimal cost, allowing it to be run by local councils and/or community groups around the UK.

The initial prototype application and user testing is being carried out in Bath & North East Somerset. The work is a joint project between Bath: Hacked, Transition Bath, Resource Futures and B&NES council.

The project has been funded by an award from the Open Data Institute summer showcase 2016.

# For Users

Development of the application and documentation is in progress. Please check back later for more information.

For now you may wish to read the evolving documentation in [the project wiki](https://github.com/BathHacked/energy-sparks/wiki).

# For Developers

The application is a Rails 5.2, Ruby 2.5.3 project.

Read the CONTRIBUTING.md guidelines for how to get started.

## Extra notes

Development mode uses mail catcher for sending mails - you need to install the [mailcatcher gem](https://github.com/sj26/mailcatcher) for this to work correctly.

## Refreshing test db

1) Get DB dump from production
2) Search and replace the production user with the test user in the sql file
3) On test, drop all tables, schema
4) Run psql against test database and import database

```
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

You may also need to restore the default grants.

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
```

## More notes on environment creation

* Create web version
* In More options
capacity:

environment: Load balanced (1 - 1)
 add classic load balance

Load Balancer:

Classic load balancer

Instances:

Set instances to t2.small

Security:

Add previously created key in security
IAM DevOps

Software:

Add environment properties

* For existing database:

Get the RDS launch wizard group and add access INBOUND for the AWSEBSecurityGroup created by EB for the new instance

Deploy latest code
Check SSH works
Set up DNS in Route 53
Set up cert and get it to create DNS record
Wait for it to be validated, then add to load balancer

(Add 443 listener)

* For new database:

1) Set up appropriate database in RDS - make sure the password doesn't have any (or too many) special characters, best to keep to digits and letters if possible!
2) Use pg_dump to get dump of current production database
3) Use psql to get data into new database

