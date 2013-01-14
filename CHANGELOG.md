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

## 0.6.1 (January 14, 2013)

Changes:

  - Existing metric groups are used rather than automatically versioning metric group name upon creation.