## 0.6.3 (May 10, 2017)

  - Added a parameter to detect dashboards created by database scripts to list them under databases tab on UI


## 0.6.2 (February 10, 2017)

  - Added service parameter to copperegg metric group API. Used for creating custom alerts according to the service being monitored (if service is installed from UI)

## 0.6.1 (January 17, 2013)

Changes:

  - Existing metric groups are used rather than automatically versioning metric group name upon creation.


## 0.6.0 (January 3, 2013)

Changes:

  - Substantial changes to syntax. API resources now represented by Ruby classes. See README for details.
  - Replaced multi_json requirement with json_pure.

Features:

  - Automatic dashboard creation for metric groups.
  - Metric groups and custom dashboards can be updated and deleted.
  - Client-side validation added.
  - Added automated test suite.

Bugfixes:

  - Metric group versioning is encorporated and recognized.


## 0.5.3 (Dec 21, 2012)

Changes:

  - Remove Gemfile.lock from git tracking

Bugfixes:

  - format to match changes in CopperEgg API


## 0.5.2 (Dec 3, 2012)

Bugfixes:

  - add explicit requires to make 1.8.7 work


## 0.5.1 (Nov 5, 2012)

Changes:

  - Use SSL
  - updated gemspec and variable names


## 0.5.0 (Nov 5, 2012)

Initial commit

