## 0.6.0.pre (January 3, 2013)

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

## 0.6.0.pre2 (January 3, 2013)

Changes:

  - MetricSample.save returns HTTP response

Bugfixes:

  - Fixed some MetricGroup and CustomDashboard validations